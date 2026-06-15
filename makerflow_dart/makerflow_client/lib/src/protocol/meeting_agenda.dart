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

/// Tactical meeting agenda. Items hang off it (meeting_item).
abstract class MeetingAgenda implements _i1.SerializableModel {
  MeetingAgenda._({
    this.id,
    required this.organizationId,
    required this.title,
    this.meetingAt,
    String? status,
    this.ownerUserInfoId,
    this.teamId,
    this.spaceId,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : status = status ?? 'draft';

  factory MeetingAgenda({
    int? id,
    required int organizationId,
    required String title,
    DateTime? meetingAt,
    String? status,
    int? ownerUserInfoId,
    int? teamId,
    int? spaceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _MeetingAgendaImpl;

  factory MeetingAgenda.fromJson(Map<String, dynamic> jsonSerialization) {
    return MeetingAgenda(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      title: jsonSerialization['title'] as String,
      meetingAt: jsonSerialization['meetingAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['meetingAt']),
      status: jsonSerialization['status'] as String?,
      ownerUserInfoId: jsonSerialization['ownerUserInfoId'] as int?,
      teamId: jsonSerialization['teamId'] as int?,
      spaceId: jsonSerialization['spaceId'] as int?,
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

  String title;

  DateTime? meetingAt;

  String status;

  int? ownerUserInfoId;

  int? teamId;

  int? spaceId;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [MeetingAgenda]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MeetingAgenda copyWith({
    int? id,
    int? organizationId,
    String? title,
    DateTime? meetingAt,
    String? status,
    int? ownerUserInfoId,
    int? teamId,
    int? spaceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MeetingAgenda',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'title': title,
      if (meetingAt != null) 'meetingAt': meetingAt?.toJson(),
      'status': status,
      if (ownerUserInfoId != null) 'ownerUserInfoId': ownerUserInfoId,
      if (teamId != null) 'teamId': teamId,
      if (spaceId != null) 'spaceId': spaceId,
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

class _MeetingAgendaImpl extends MeetingAgenda {
  _MeetingAgendaImpl({
    int? id,
    required int organizationId,
    required String title,
    DateTime? meetingAt,
    String? status,
    int? ownerUserInfoId,
    int? teamId,
    int? spaceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         title: title,
         meetingAt: meetingAt,
         status: status,
         ownerUserInfoId: ownerUserInfoId,
         teamId: teamId,
         spaceId: spaceId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [MeetingAgenda]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MeetingAgenda copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? title,
    Object? meetingAt = _Undefined,
    String? status,
    Object? ownerUserInfoId = _Undefined,
    Object? teamId = _Undefined,
    Object? spaceId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return MeetingAgenda(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      title: title ?? this.title,
      meetingAt: meetingAt is DateTime? ? meetingAt : this.meetingAt,
      status: status ?? this.status,
      ownerUserInfoId: ownerUserInfoId is int?
          ? ownerUserInfoId
          : this.ownerUserInfoId,
      teamId: teamId is int? ? teamId : this.teamId,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
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
