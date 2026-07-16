import 'dart:convert';

import 'package:flutter/material.dart';

/// Client-side view of a custom-field definition (FieldConfig on the server,
/// fl-8-custom-fields). Options carry the label colors for `label` fields.
class FieldConfigVm {
  const FieldConfigVm({
    this.id,
    required this.key,
    required this.label,
    required this.fieldType,
    this.options = const [],
    this.required = false,
  });

  final int? id;
  final String key;
  final String label;
  final String fieldType;
  final List<FieldOption> options;
  final bool required;

  FieldConfigVm copyWith({String? label, String? fieldType, List<FieldOption>? options}) =>
      FieldConfigVm(
        id: id,
        key: key,
        label: label ?? this.label,
        fieldType: fieldType ?? this.fieldType,
        options: options ?? this.options,
        required: required,
      );

  /// The tier-1 field types the platform accepts (mirrors the server's
  /// FieldConfigEndpoint.allowedFieldTypes — the server is the authority).
  static const fieldTypes = [
    'text', 'longText', 'number', 'date', 'select', 'multiSelect',
    'person', 'checkbox', 'label',
  ];

  static const typeLabels = {
    'text': 'Text',
    'longText': 'Long text',
    'number': 'Number',
    'date': 'Date',
    'select': 'Dropdown',
    'multiSelect': 'Tags (multi-select)',
    'person': 'Person',
    'checkbox': 'Checkbox',
    'label': 'Label (colored)',
  };

  /// Canonical wire format for optionsJson: an array of strings or
  /// `{"value": ..., "color": "#RRGGBB"}` objects (server parses both).
  String encodeOptions() => jsonEncode([
        for (final o in options)
          o.color == null
              ? o.value
              : {'value': o.value, 'color': _hex(o.color!)},
      ]);

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

  /// Tolerant optionsJson parse (mirrors the server's CustomFields.optionValues).
  static List<FieldOption> decodeOptions(String? optionsJson) {
    if (optionsJson == null || optionsJson.trim().isEmpty) return const [];
    try {
      final raw = jsonDecode(optionsJson);
      if (raw is! List) return const [];
      return [
        for (final e in raw)
          if (e is String)
            FieldOption(e)
          else if (e is Map<String, dynamic> && e['value'] is String)
            FieldOption(e['value'] as String, color: _parseHex(e['color'])),
      ];
    } catch (_) {
      return const [];
    }
  }

  static Color? _parseHex(Object? hex) {
    if (hex is! String) return null;
    final cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) return null;
    final v = int.tryParse(cleaned, radix: 16);
    return v == null ? null : Color(0xFF000000 | v);
  }

  /// A storage key derived from a display label: `Weight (kg)` -> `weight_kg`.
  static String keyFromLabel(String label) {
    final k = label
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return k.isEmpty ? 'field' : k;
  }
}

class FieldOption {
  const FieldOption(this.value, {this.color});
  final String value;
  final Color? color;
}
