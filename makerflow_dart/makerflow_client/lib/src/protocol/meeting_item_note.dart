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

/// Timeline entry (note/comment) on a meeting item.
/// NB: named *Note*, not *Update* — Serverpod generates a `MeetingItemUpdateTable`
/// helper for the `MeetingItem` model, which would collide with a model named
/// `MeetingItemUpdate`.
abstract class MeetingItemNote implements _i1.SerializableModel {
  MeetingItemNote._({
    this.id,
    required this.organizationId,
    required this.itemId,
    required this.body,
    required this.createdAt,
    this.createdByUserInfoId,
  });

  factory MeetingItemNote({
    int? id,
    required int organizationId,
    required int itemId,
    required String body,
    required DateTime createdAt,
    int? createdByUserInfoId,
  }) = _MeetingItemNoteImpl;

  factory MeetingItemNote.fromJson(Map<String, dynamic> jsonSerialization) {
    return MeetingItemNote(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      itemId: jsonSerialization['itemId'] as int,
      body: jsonSerialization['body'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      createdByUserInfoId: jsonSerialization['createdByUserInfoId'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  int itemId;

  String body;

  DateTime createdAt;

  int? createdByUserInfoId;

  /// Returns a shallow copy of this [MeetingItemNote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MeetingItemNote copyWith({
    int? id,
    int? organizationId,
    int? itemId,
    String? body,
    DateTime? createdAt,
    int? createdByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MeetingItemNote',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'itemId': itemId,
      'body': body,
      'createdAt': createdAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MeetingItemNoteImpl extends MeetingItemNote {
  _MeetingItemNoteImpl({
    int? id,
    required int organizationId,
    required int itemId,
    required String body,
    required DateTime createdAt,
    int? createdByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         itemId: itemId,
         body: body,
         createdAt: createdAt,
         createdByUserInfoId: createdByUserInfoId,
       );

  /// Returns a shallow copy of this [MeetingItemNote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MeetingItemNote copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? itemId,
    String? body,
    DateTime? createdAt,
    Object? createdByUserInfoId = _Undefined,
  }) {
    return MeetingItemNote(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      itemId: itemId ?? this.itemId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      createdByUserInfoId: createdByUserInfoId is int?
          ? createdByUserInfoId
          : this.createdByUserInfoId,
    );
  }
}
