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

/// Threaded comment on any entity (polymorphic via entityType+entityId).
/// Org-scoped, soft-deletable, audited, offline-cacheable.
abstract class ItemComment implements _i1.SerializableModel {
  ItemComment._({
    this.id,
    required this.organizationId,
    required this.entityType,
    required this.entityId,
    this.parentCommentId,
    required this.body,
    this.clientUuid,
    int? version,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : version = version ?? 1;

  factory ItemComment({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    int? parentCommentId,
    required String body,
    String? clientUuid,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _ItemCommentImpl;

  factory ItemComment.fromJson(Map<String, dynamic> jsonSerialization) {
    return ItemComment(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as int,
      parentCommentId: jsonSerialization['parentCommentId'] as int?,
      body: jsonSerialization['body'] as String,
      clientUuid: jsonSerialization['clientUuid'] as String?,
      version: jsonSerialization['version'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      createdByUserInfoId: jsonSerialization['createdByUserInfoId'] as int?,
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

  String entityType;

  int entityId;

  int? parentCommentId;

  String body;

  String? clientUuid;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [ItemComment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ItemComment copyWith({
    int? id,
    int? organizationId,
    String? entityType,
    int? entityId,
    int? parentCommentId,
    String? body,
    String? clientUuid,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ItemComment',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'entityId': entityId,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      'body': body,
      if (clientUuid != null) 'clientUuid': clientUuid,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
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

class _ItemCommentImpl extends ItemComment {
  _ItemCommentImpl({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    int? parentCommentId,
    required String body,
    String? clientUuid,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         entityType: entityType,
         entityId: entityId,
         parentCommentId: parentCommentId,
         body: body,
         clientUuid: clientUuid,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [ItemComment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ItemComment copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? entityType,
    int? entityId,
    Object? parentCommentId = _Undefined,
    String? body,
    Object? clientUuid = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return ItemComment(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      parentCommentId: parentCommentId is int?
          ? parentCommentId
          : this.parentCommentId,
      body: body ?? this.body,
      clientUuid: clientUuid is String? ? clientUuid : this.clientUuid,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUserInfoId: createdByUserInfoId is int?
          ? createdByUserInfoId
          : this.createdByUserInfoId,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByUserInfoId: deletedByUserInfoId is int?
          ? deletedByUserInfoId
          : this.deletedByUserInfoId,
    );
  }
}
