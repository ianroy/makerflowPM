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

/// Append-only action trace. Written by the central audit interceptor on every
/// mutation (docs/SECURITY.md). Never soft-deleted; never purged.
abstract class AuditLog implements _i1.SerializableModel {
  AuditLog._({
    this.id,
    required this.organizationId,
    this.actorUserInfoId,
    required this.entityType,
    this.entityId,
    required this.action,
    this.payloadHash,
    this.summary,
    required this.createdAt,
  });

  factory AuditLog({
    int? id,
    required int organizationId,
    int? actorUserInfoId,
    required String entityType,
    int? entityId,
    required String action,
    String? payloadHash,
    String? summary,
    required DateTime createdAt,
  }) = _AuditLogImpl;

  factory AuditLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditLog(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      actorUserInfoId: jsonSerialization['actorUserInfoId'] as int?,
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as int?,
      action: jsonSerialization['action'] as String,
      payloadHash: jsonSerialization['payloadHash'] as String?,
      summary: jsonSerialization['summary'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  int? actorUserInfoId;

  String entityType;

  int? entityId;

  String action;

  String? payloadHash;

  String? summary;

  DateTime createdAt;

  /// Returns a shallow copy of this [AuditLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuditLog copyWith({
    int? id,
    int? organizationId,
    int? actorUserInfoId,
    String? entityType,
    int? entityId,
    String? action,
    String? payloadHash,
    String? summary,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuditLog',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      if (actorUserInfoId != null) 'actorUserInfoId': actorUserInfoId,
      'entityType': entityType,
      if (entityId != null) 'entityId': entityId,
      'action': action,
      if (payloadHash != null) 'payloadHash': payloadHash,
      if (summary != null) 'summary': summary,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditLogImpl extends AuditLog {
  _AuditLogImpl({
    int? id,
    required int organizationId,
    int? actorUserInfoId,
    required String entityType,
    int? entityId,
    required String action,
    String? payloadHash,
    String? summary,
    required DateTime createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         actorUserInfoId: actorUserInfoId,
         entityType: entityType,
         entityId: entityId,
         action: action,
         payloadHash: payloadHash,
         summary: summary,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AuditLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuditLog copyWith({
    Object? id = _Undefined,
    int? organizationId,
    Object? actorUserInfoId = _Undefined,
    String? entityType,
    Object? entityId = _Undefined,
    String? action,
    Object? payloadHash = _Undefined,
    Object? summary = _Undefined,
    DateTime? createdAt,
  }) {
    return AuditLog(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      actorUserInfoId: actorUserInfoId is int?
          ? actorUserInfoId
          : this.actorUserInfoId,
      entityType: entityType ?? this.entityType,
      entityId: entityId is int? ? entityId : this.entityId,
      action: action ?? this.action,
      payloadHash: payloadHash is String? ? payloadHash : this.payloadHash,
      summary: summary is String? ? summary : this.summary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
