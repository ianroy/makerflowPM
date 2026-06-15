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

/// Saved report configuration (per org, visibility-scoped).
abstract class ReportTemplate implements _i1.SerializableModel {
  ReportTemplate._({
    this.id,
    required this.organizationId,
    required this.name,
    required this.configJson,
    String? visibility,
    this.ownerUserInfoId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : visibility = visibility ?? 'org';

  factory ReportTemplate({
    int? id,
    required int organizationId,
    required String name,
    required String configJson,
    String? visibility,
    int? ownerUserInfoId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _ReportTemplateImpl;

  factory ReportTemplate.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReportTemplate(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      configJson: jsonSerialization['configJson'] as String,
      visibility: jsonSerialization['visibility'] as String?,
      ownerUserInfoId: jsonSerialization['ownerUserInfoId'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      deletedByUserInfoId: jsonSerialization['deletedByUserInfoId'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  String name;

  String configJson;

  String visibility;

  int? ownerUserInfoId;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [ReportTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ReportTemplate copyWith({
    int? id,
    int? organizationId,
    String? name,
    String? configJson,
    String? visibility,
    int? ownerUserInfoId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReportTemplate',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      'configJson': configJson,
      'visibility': visibility,
      if (ownerUserInfoId != null) 'ownerUserInfoId': ownerUserInfoId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReportTemplateImpl extends ReportTemplate {
  _ReportTemplateImpl({
    int? id,
    required int organizationId,
    required String name,
    required String configJson,
    String? visibility,
    int? ownerUserInfoId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         configJson: configJson,
         visibility: visibility,
         ownerUserInfoId: ownerUserInfoId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [ReportTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ReportTemplate copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    String? configJson,
    String? visibility,
    Object? ownerUserInfoId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return ReportTemplate(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      configJson: configJson ?? this.configJson,
      visibility: visibility ?? this.visibility,
      ownerUserInfoId: ownerUserInfoId is int?
          ? ownerUserInfoId
          : this.ownerUserInfoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByUserInfoId: deletedByUserInfoId is int?
          ? deletedByUserInfoId
          : this.deletedByUserInfoId,
    );
  }
}
