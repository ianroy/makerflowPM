/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// Per-org custom field definition applied to an entity type.
abstract class FieldConfig implements _i1.SerializableModel {
  FieldConfig._({
    this.id,
    required this.organizationId,
    required this.entityType,
    required this.key,
    required this.label,
    required this.fieldType,
    this.optionsJson,
    bool? required,
    double? sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : required = required ?? false,
       sortOrder = sortOrder ?? 0.0;

  factory FieldConfig({
    int? id,
    required int organizationId,
    required String entityType,
    required String key,
    required String label,
    required String fieldType,
    String? optionsJson,
    bool? required,
    double? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FieldConfigImpl;

  factory FieldConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return FieldConfig(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      entityType: jsonSerialization['entityType'] as String,
      key: jsonSerialization['key'] as String,
      label: jsonSerialization['label'] as String,
      fieldType: jsonSerialization['fieldType'] as String,
      optionsJson: jsonSerialization['optionsJson'] as String?,
      required: jsonSerialization['required'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['required']),
      sortOrder: (jsonSerialization['sortOrder'] as num?)?.toDouble(),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  String entityType;

  String key;

  String label;

  String fieldType;

  String? optionsJson;

  bool required;

  double sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [FieldConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FieldConfig copyWith({
    int? id,
    int? organizationId,
    String? entityType,
    String? key,
    String? label,
    String? fieldType,
    String? optionsJson,
    bool? required,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FieldConfig',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'key': key,
      'label': label,
      'fieldType': fieldType,
      if (optionsJson != null) 'optionsJson': optionsJson,
      'required': required,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FieldConfigImpl extends FieldConfig {
  _FieldConfigImpl({
    int? id,
    required int organizationId,
    required String entityType,
    required String key,
    required String label,
    required String fieldType,
    String? optionsJson,
    bool? required,
    double? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         entityType: entityType,
         key: key,
         label: label,
         fieldType: fieldType,
         optionsJson: optionsJson,
         required: required,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FieldConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FieldConfig copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? entityType,
    String? key,
    String? label,
    String? fieldType,
    Object? optionsJson = _Undefined,
    bool? required,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldConfig(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      entityType: entityType ?? this.entityType,
      key: key ?? this.key,
      label: label ?? this.label,
      fieldType: fieldType ?? this.fieldType,
      optionsJson: optionsJson is String? ? optionsJson : this.optionsJson,
      required: required ?? this.required,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
