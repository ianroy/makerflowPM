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

/// Calendar-driven metadata that seeds an agenda from an external event.
abstract class MeetingNoteSource implements _i1.SerializableModel {
  MeetingNoteSource._({
    this.id,
    required this.organizationId,
    this.agendaId,
    this.calendarEventId,
    required this.sourceKind,
    this.rawJson,
    required this.createdAt,
  });

  factory MeetingNoteSource({
    int? id,
    required int organizationId,
    int? agendaId,
    int? calendarEventId,
    required String sourceKind,
    String? rawJson,
    required DateTime createdAt,
  }) = _MeetingNoteSourceImpl;

  factory MeetingNoteSource.fromJson(Map<String, dynamic> jsonSerialization) {
    return MeetingNoteSource(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      agendaId: jsonSerialization['agendaId'] as int?,
      calendarEventId: jsonSerialization['calendarEventId'] as int?,
      sourceKind: jsonSerialization['sourceKind'] as String,
      rawJson: jsonSerialization['rawJson'] as String?,
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

  int? agendaId;

  int? calendarEventId;

  String sourceKind;

  String? rawJson;

  DateTime createdAt;

  /// Returns a shallow copy of this [MeetingNoteSource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MeetingNoteSource copyWith({
    int? id,
    int? organizationId,
    int? agendaId,
    int? calendarEventId,
    String? sourceKind,
    String? rawJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MeetingNoteSource',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      if (agendaId != null) 'agendaId': agendaId,
      if (calendarEventId != null) 'calendarEventId': calendarEventId,
      'sourceKind': sourceKind,
      if (rawJson != null) 'rawJson': rawJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MeetingNoteSourceImpl extends MeetingNoteSource {
  _MeetingNoteSourceImpl({
    int? id,
    required int organizationId,
    int? agendaId,
    int? calendarEventId,
    required String sourceKind,
    String? rawJson,
    required DateTime createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         agendaId: agendaId,
         calendarEventId: calendarEventId,
         sourceKind: sourceKind,
         rawJson: rawJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MeetingNoteSource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MeetingNoteSource copyWith({
    Object? id = _Undefined,
    int? organizationId,
    Object? agendaId = _Undefined,
    Object? calendarEventId = _Undefined,
    String? sourceKind,
    Object? rawJson = _Undefined,
    DateTime? createdAt,
  }) {
    return MeetingNoteSource(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      agendaId: agendaId is int? ? agendaId : this.agendaId,
      calendarEventId: calendarEventId is int?
          ? calendarEventId
          : this.calendarEventId,
      sourceKind: sourceKind ?? this.sourceKind,
      rawJson: rawJson is String? ? rawJson : this.rawJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
