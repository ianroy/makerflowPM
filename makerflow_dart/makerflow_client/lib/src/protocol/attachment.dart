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
import 'enums/attachment_kind.dart' as _i2;

/// Object-store metadata for an uploaded file (supersedes blob storage in the
/// legacy meeting_item_files). Polymorphic via entityType+entityId. altText
/// is required for images (WCAG 1.1.1).
abstract class Attachment implements _i1.SerializableModel {
  Attachment._({
    this.id,
    required this.organizationId,
    required this.entityType,
    required this.entityId,
    _i2.AttachmentKind? kind,
    required this.filename,
    required this.contentType,
    required this.bytes,
    required this.storageKey,
    this.altText,
    required this.createdAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : kind = kind ?? _i2.AttachmentKind.other;

  factory Attachment({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    _i2.AttachmentKind? kind,
    required String filename,
    required String contentType,
    required int bytes,
    required String storageKey,
    String? altText,
    required DateTime createdAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _AttachmentImpl;

  factory Attachment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Attachment(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as int,
      kind: jsonSerialization['kind'] == null
          ? null
          : _i2.AttachmentKind.fromJson((jsonSerialization['kind'] as String)),
      filename: jsonSerialization['filename'] as String,
      contentType: jsonSerialization['contentType'] as String,
      bytes: jsonSerialization['bytes'] as int,
      storageKey: jsonSerialization['storageKey'] as String,
      altText: jsonSerialization['altText'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
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

  _i2.AttachmentKind kind;

  String filename;

  String contentType;

  int bytes;

  String storageKey;

  String? altText;

  DateTime createdAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [Attachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Attachment copyWith({
    int? id,
    int? organizationId,
    String? entityType,
    int? entityId,
    _i2.AttachmentKind? kind,
    String? filename,
    String? contentType,
    int? bytes,
    String? storageKey,
    String? altText,
    DateTime? createdAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Attachment',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'entityId': entityId,
      'kind': kind.toJson(),
      'filename': filename,
      'contentType': contentType,
      'bytes': bytes,
      'storageKey': storageKey,
      if (altText != null) 'altText': altText,
      'createdAt': createdAt.toJson(),
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

class _AttachmentImpl extends Attachment {
  _AttachmentImpl({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    _i2.AttachmentKind? kind,
    required String filename,
    required String contentType,
    required int bytes,
    required String storageKey,
    String? altText,
    required DateTime createdAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         entityType: entityType,
         entityId: entityId,
         kind: kind,
         filename: filename,
         contentType: contentType,
         bytes: bytes,
         storageKey: storageKey,
         altText: altText,
         createdAt: createdAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [Attachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Attachment copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? entityType,
    int? entityId,
    _i2.AttachmentKind? kind,
    String? filename,
    String? contentType,
    int? bytes,
    String? storageKey,
    Object? altText = _Undefined,
    DateTime? createdAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return Attachment(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      kind: kind ?? this.kind,
      filename: filename ?? this.filename,
      contentType: contentType ?? this.contentType,
      bytes: bytes ?? this.bytes,
      storageKey: storageKey ?? this.storageKey,
      altText: altText is String? ? altText : this.altText,
      createdAt: createdAt ?? this.createdAt,
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
