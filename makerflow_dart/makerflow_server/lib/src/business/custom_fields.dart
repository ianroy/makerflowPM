import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// D6 custom-field VALUES (fl-8-custom-fields): a JSON object on the entity
/// (`Task.customFieldsJson`), keyed by `FieldConfig.key`. This module is the
/// single authority for what a value bag may contain — every task write path
/// validates through [validate], and a FieldConfig type change converts
/// existing values through [coerceValue].
///
/// Value shapes by field type:
///   text / longText  String
///   number           num
///   checkbox         bool
///   date             ISO-8601 String (parseable by DateTime.parse)
///   person           int (serverpod userInfoId)
///   select / label   String — must be one of the definition's options
///   multiSelect      List<String> — subset of the definition's options
/// `null` clears a value. Keys without a definition are rejected.
class CustomFields {
  /// Validate a value bag against the org's field definitions.
  /// Throws a typed [MakerflowConflictException] naming the offending field.
  static Future<void> validate(
    Session session,
    int organizationId,
    String entityType,
    String? customFieldsJson,
  ) async {
    if (customFieldsJson == null || customFieldsJson.trim().isEmpty) return;

    final Object? decoded;
    try {
      decoded = jsonDecode(customFieldsJson);
    } catch (_) {
      throw MakerflowConflictException(
          message: 'customFieldsJson is not valid JSON.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw MakerflowConflictException(
          message: 'customFieldsJson must be a JSON object keyed by field key.');
    }
    if (decoded.isEmpty) return;

    final configs = await FieldConfig.db.find(
      session,
      where: (f) =>
          f.organizationId.equals(organizationId) &
          f.entityType.equals(entityType),
    );
    final byKey = {for (final c in configs) c.key: c};

    for (final entry in decoded.entries) {
      final config = byKey[entry.key];
      if (config == null) {
        throw MakerflowConflictException(
            message: 'No field definition for "${entry.key}" on $entityType. '
                'Define it first (FieldConfigEndpoint.save).');
      }
      final value = entry.value;
      if (value == null) continue; // null clears the value
      final problem = typeProblem(config, value);
      if (problem != null) {
        throw MakerflowConflictException(
            message: 'Field "${config.key}" (${config.fieldType}) $problem.');
      }
    }
  }

  /// Null when [value] fits [config]'s type; otherwise a human-readable
  /// description of the mismatch.
  static String? typeProblem(FieldConfig config, Object value) {
    switch (config.fieldType) {
      case 'text':
      case 'longText':
        return value is String ? null : 'expects a string';
      case 'number':
        return value is num ? null : 'expects a number';
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
        if (value is num) return value;
        if (value is String) return num.tryParse(value);
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
