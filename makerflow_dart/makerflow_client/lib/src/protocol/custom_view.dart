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

/// Saved filter/column set (per user, optionally shared). filtersJson and
/// columnsJson hold serialized config (the legacy custom_views payload).
abstract class CustomView implements _i1.SerializableModel {
  CustomView._({
    this.id,
    required this.organizationId,
    required this.ownerUserInfoId,
    required this.name,
    required this.entityType,
    String? viewType,
    required this.filtersJson,
    required this.columnsJson,
    bool? isShared,
    int? version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : viewType = viewType ?? 'table',
       isShared = isShared ?? false,
       version = version ?? 1;

  factory CustomView({
    int? id,
    required int organizationId,
    required int ownerUserInfoId,
    required String name,
    required String entityType,
    String? viewType,
    required String filtersJson,
    required String columnsJson,
    bool? isShared,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _CustomViewImpl;

  factory CustomView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomView(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      ownerUserInfoId: jsonSerialization['ownerUserInfoId'] as int,
      name: jsonSerialization['name'] as String,
      entityType: jsonSerialization['entityType'] as String,
      viewType: jsonSerialization['viewType'] as String?,
      filtersJson: jsonSerialization['filtersJson'] as String,
      columnsJson: jsonSerialization['columnsJson'] as String,
      isShared: jsonSerialization['isShared'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isShared']),
      version: jsonSerialization['version'] as int?,
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

  int ownerUserInfoId;

  String name;

  String entityType;

  String viewType;

  String filtersJson;

  String columnsJson;

  bool isShared;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [CustomView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CustomView copyWith({
    int? id,
    int? organizationId,
    int? ownerUserInfoId,
    String? name,
    String? entityType,
    String? viewType,
    String? filtersJson,
    String? columnsJson,
    bool? isShared,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomView',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'ownerUserInfoId': ownerUserInfoId,
      'name': name,
      'entityType': entityType,
      'viewType': viewType,
      'filtersJson': filtersJson,
      'columnsJson': columnsJson,
      'isShared': isShared,
      'version': version,
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

class _CustomViewImpl extends CustomView {
  _CustomViewImpl({
    int? id,
    required int organizationId,
    required int ownerUserInfoId,
    required String name,
    required String entityType,
    String? viewType,
    required String filtersJson,
    required String columnsJson,
    bool? isShared,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         ownerUserInfoId: ownerUserInfoId,
         name: name,
         entityType: entityType,
         viewType: viewType,
         filtersJson: filtersJson,
         columnsJson: columnsJson,
         isShared: isShared,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [CustomView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CustomView copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? ownerUserInfoId,
    String? name,
    String? entityType,
    String? viewType,
    String? filtersJson,
    String? columnsJson,
    bool? isShared,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return CustomView(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      ownerUserInfoId: ownerUserInfoId ?? this.ownerUserInfoId,
      name: name ?? this.name,
      entityType: entityType ?? this.entityType,
      viewType: viewType ?? this.viewType,
      filtersJson: filtersJson ?? this.filtersJson,
      columnsJson: columnsJson ?? this.columnsJson,
      isShared: isShared ?? this.isShared,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByUserInfoId: deletedByUserInfoId is int?
          ? deletedByUserInfoId
          : this.deletedByUserInfoId,
    );
  }
}
