import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// D6 custom-field VALUES (fl-8-custom-fields): a JSON object on the entity
/// (`Task.customFieldsJson`), keyed by `FieldConfig.key`. This module is the
/// single authority for what a value bag may contain — every task write path
/// runs through [sanitize], and a FieldConfig type change converts existing
/// values through [coerceValue].
///
/// Value shapes by field type:
///   text / longText  String
///   number           finite num
///   checkbox         bool
///   date             ISO-8601 String (parseable by DateTime.parse)
///   person           int (serverpod userInfoId)
///   select / label   String — must be one of the definition's options
///   multiSelect      List<String> — subset of the definition's options
///
/// Write rules (the schema-evolution contract):
///   • `null` clears a value (removed from the stored document).
///   • NEW or CHANGED values are strictly validated — unknown keys and type/
///     option mismatches throw a typed Conflict.
///   • Values CARRIED UNCHANGED from the existing row are kept even when the
///     schema has moved under them (definition deleted, option removed, type
///     changed elsewhere) — so a fetch-merge edit of an unrelated field can
///     never brick a task. Readers render such orphans tolerantly.
///   • The stored document is a canonical re-encode of the validated map —
///     never the client's raw bytes (kills duplicate-key smuggling).
class CustomFields {
  /// Validate [incomingJson] against the org's definitions and return the
  /// canonical document to store (null in = null out). [existingJson] is the
  /// row's current document; values equal to their stored counterpart are
  /// exempt from re-validation (see the class contract above).
  /// Throws a typed [MakerflowConflictException] naming the offending field.
  static Future<String?> sanitize(
    Session session,
    int organizationId,
    String entityType,
    String? incomingJson, {
    String? existingJson,
  }) async {
    if (incomingJson == null || incomingJson.trim().isEmpty) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(incomingJson);
    } catch (_) {
      throw MakerflowConflictException(
          message: 'customFieldsJson is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw MakerflowConflictException(
          message: 'customFieldsJson must be a JSON object keyed by field key.');
    }
    if (decoded.isEmpty) return '{}';

    final existing = decodeBag(existingJson);
    final configs = await FieldConfig.db.find(
      session,
      where: (f) =>
          f.organizationId.equals(organizationId) &
          f.entityType.equals(entityType),
    );
    final byKey = {for (final c in configs) c.key: c};

    final out = <String, dynamic>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value == null) continue; // null clears the value
      final carried = existing.containsKey(entry.key) &&
          _jsonEquals(existing[entry.key], value);
      if (carried) {
        out[entry.key] = value; // unchanged → keep, even if schema moved
        continue;
      }
      final config = byKey[entry.key];
      if (config == null) {
        throw MakerflowConflictException(
            message: 'No field definition for "${entry.key}" on $entityType. '
                'Define it first (FieldConfigEndpoint.save).');
      }
      final problem = typeProblem(config, value);
      if (problem != null) {
        throw MakerflowConflictException(
            message: 'Field "${config.key}" (${config.fieldType}) $problem.');
      }
      out[entry.key] = value;
    }
    return jsonEncode(out);
  }

  /// Structural equality for JSON scalars and lists (the only value shapes).
  static bool _jsonEquals(Object? a, Object? b) {
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }
    return a == b;
  }

  /// Null when [value] fits [config]'s type; otherwise a human-readable
  /// description of the mismatch.
  static String? typeProblem(FieldConfig config, Object value) {
    switch (config.fieldType) {
      case 'text':
      case 'longText':
        return value is String ? null : 'expects a string';
      case 'number':
        // Non-finite values (1e999 → Infinity) would crash jsonEncode later.
        return (value is num && value.isFinite) ? null : 'expects a finite number';
      case 'checkbox':
        return value is bool ? null : 'expects true/false';
      case 'date':
        if (value is! String || DateTime.tryParse(value) == null) {
          return 'expects an ISO-8601 date string';
        }
        return null;
      case 'person':
        return value is int ? null : 'expects a userInfoId (integer)';
      case 'select':
      case 'label':
        if (value is! String) return 'expects a string option';
        final options = optionValues(config.optionsJson);
        if (options.isNotEmpty && !options.contains(value)) {
          return 'expects one of: ${options.join(', ')}';
        }
        return null;
      case 'multiSelect':
        if (value is! List || value.any((e) => e is! String)) {
          return 'expects a list of string options';
        }
        final options = optionValues(config.optionsJson);
        if (options.isNotEmpty &&
            !value.every((e) => options.contains(e as String))) {
          return 'expects a subset of: ${options.join(', ')}';
        }
        return null;
      default:
        return 'has an unknown field type';
    }
  }

  /// The option VALUES of a select/multiSelect/label definition. Tolerant:
  /// accepts `["a","b"]` and `[{"value":"a","color":"#..."}]` (and mixes);
  /// malformed JSON yields an empty list (= any string accepted).
  static List<String> optionValues(String? optionsJson) {
    if (optionsJson == null || optionsJson.trim().isEmpty) return const [];
    try {
      final raw = jsonDecode(optionsJson);
      if (raw is! List) return const [];
      return [
        for (final e in raw)
          if (e is String)
            e
          else if (e is Map<String, dynamic> && e['value'] is String)
            e['value'] as String,
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Best-effort conversion of an existing value when a definition changes
  /// type (the Airtable pattern). Returns the coerced value, or `null` when
  /// there is no safe conversion (the value is cleared).
  static Object? coerceValue(Object? value, FieldConfig to) {
    if (value == null) return null;
    switch (to.fieldType) {
      case 'text':
      case 'longText':
        if (value is List) return value.join(', ');
        return value.toString();
      case 'number':
        if (value is num) return value.isFinite ? value : null;
        if (value is String) {
          final n = num.tryParse(value);
          return (n != null && n.isFinite) ? n : null;
        }
        return null;
      case 'checkbox':
        if (value is bool) return value;
        if (value is String) {
          if (value.toLowerCase() == 'true') return true;
          if (value.toLowerCase() == 'false') return false;
        }
        return null;
      case 'date':
        if (value is String && DateTime.tryParse(value) != null) return value;
        return null;
      case 'person':
        return value is int ? value : null;
      case 'select':
      case 'label':
        final options = optionValues(to.optionsJson);
        String? candidate;
        if (value is String) candidate = value;
        if (value is List && value.length == 1 && value.first is String) {
          candidate = value.first as String;
        }
        if (candidate == null) return null;
        return (options.isEmpty || options.contains(candidate)) ? candidate : null;
      case 'multiSelect':
        final options = optionValues(to.optionsJson);
        List<String>? list;
        if (value is String) list = [value];
        if (value is List && value.every((e) => e is String)) {
          list = value.cast<String>();
        }
        if (list == null) return null;
        final kept = options.isEmpty
            ? list
            : list.where(options.contains).toList();
        return kept.isEmpty ? null : kept;
      default:
        return null;
    }
  }

  /// Rewrite every live task value for [config]'s key to fit its (new) type.
  /// Returns the number of rows changed. Bumps `version`/`updatedAt` on each
  /// touched row so offline clients reconcile.
  static Future<int> coerceTaskValues(Session session, FieldConfig config) async {
    final tasks = await Task.db.find(
      session,
      where: (t) =>
          t.organizationId.equals(config.organizationId) &
          t.deletedAt.equals(null) &
          t.customFieldsJson.notEquals(null),
    );
    var changed = 0;
    final now = DateTime.now().toUtc();
    for (final task in tasks) {
      final bag = decodeBag(task.customFieldsJson);
      if (!bag.containsKey(config.key)) continue;
      final coerced = coerceValue(bag[config.key], config);
      if (coerced == null) {
        bag.remove(config.key);
      } else {
        bag[config.key] = coerced;
      }
      await Task.db.updateRow(
        session,
        task.copyWith(
          customFieldsJson: jsonEncode(bag),
          version: task.version + 1,
          updatedAt: now,
        ),
      );
      changed++;
    }
    return changed;
  }

  /// How many live tasks carry a value for [config]'s key.
  static Future<int> countTaskValues(Session session, FieldConfig config) async {
    final tasks = await Task.db.find(
      session,
      where: (t) =>
          t.organizationId.equals(config.organizationId) &
          t.deletedAt.equals(null) &
          t.customFieldsJson.notEquals(null),
    );
    return tasks
        .where((t) => decodeBag(t.customFieldsJson).containsKey(config.key))
        .length;
  }

  /// Tolerant decode of a stored bag (malformed → empty map, never throws).
  static Map<String, dynamic> decodeBag(String? customFieldsJson) {
    if (customFieldsJson == null || customFieldsJson.trim().isEmpty) return {};
    try {
      final raw = jsonDecode(customFieldsJson);
      return raw is Map<String, dynamic> ? raw : {};
    } catch (_) {
      return {};
    }
  }
}
