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

/// Imported/synced schedule record (Google Calendar or ICS import).
abstract class CalendarEvent implements _i1.SerializableModel {
  CalendarEvent._({
    this.id,
    required this.organizationId,
    required this.title,
    required this.startAt,
    this.endAt,
    String? source,
    this.externalId,
    required this.createdAt,
    required this.updatedAt,
  }) : source = source ?? 'manual';

  factory CalendarEvent({
    int? id,
    required int organizationId,
    required String title,
    required DateTime startAt,
    DateTime? endAt,
    String? source,
    String? externalId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarEventImpl;

  factory CalendarEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEvent(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      title: jsonSerialization['title'] as String,
      startAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['startAt']),
      endAt: jsonSerialization['endAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['endAt']),
      source: jsonSerialization['source'] as String?,
      externalId: jsonSerialization['externalId'] as String?,
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

  String title;

  DateTime startAt;

  DateTime? endAt;

  String source;

  String? externalId;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [CalendarEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CalendarEvent copyWith({
    int? id,
    int? organizationId,
    String? title,
    DateTime? startAt,
    DateTime? endAt,
    String? source,
    String? externalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CalendarEvent',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'title': title,
      'startAt': startAt.toJson(),
      if (endAt != null) 'endAt': endAt?.toJson(),
      'source': source,
      if (externalId != null) 'externalId': externalId,
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

class _CalendarEventImpl extends CalendarEvent {
  _CalendarEventImpl({
    int? id,
    required int organizationId,
    required String title,
    required DateTime startAt,
    DateTime? endAt,
    String? source,
    String? externalId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         title: title,
         startAt: startAt,
         endAt: endAt,
         source: source,
         externalId: externalId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CalendarEvent copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? title,
    DateTime? startAt,
    Object? endAt = _Undefined,
    String? source,
    Object? externalId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      title: title ?? this.title,
      startAt: startAt ?? this.startAt,
      endAt: endAt is DateTime? ? endAt : this.endAt,
      source: source ?? this.source,
      externalId: externalId is String? ? externalId : this.externalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
