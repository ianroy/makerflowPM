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

/// Bidirectional bridge between a MakerFlow task and a Google event.
abstract class CalendarSyncLink implements _i1.SerializableModel {
  CalendarSyncLink._({
    this.id,
    required this.organizationId,
    required this.taskId,
    required this.externalEventId,
    this.lastPushedAt,
    this.lastPulledAt,
  });

  factory CalendarSyncLink({
    int? id,
    required int organizationId,
    required int taskId,
    required String externalEventId,
    DateTime? lastPushedAt,
    DateTime? lastPulledAt,
  }) = _CalendarSyncLinkImpl;

  factory CalendarSyncLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarSyncLink(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      taskId: jsonSerialization['taskId'] as int,
      externalEventId: jsonSerialization['externalEventId'] as String,
      lastPushedAt: jsonSerialization['lastPushedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastPushedAt'],
            ),
      lastPulledAt: jsonSerialization['lastPulledAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastPulledAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  int taskId;

  String externalEventId;

  DateTime? lastPushedAt;

  DateTime? lastPulledAt;

  /// Returns a shallow copy of this [CalendarSyncLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CalendarSyncLink copyWith({
    int? id,
    int? organizationId,
    int? taskId,
    String? externalEventId,
    DateTime? lastPushedAt,
    DateTime? lastPulledAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CalendarSyncLink',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'taskId': taskId,
      'externalEventId': externalEventId,
      if (lastPushedAt != null) 'lastPushedAt': lastPushedAt?.toJson(),
      if (lastPulledAt != null) 'lastPulledAt': lastPulledAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSyncLinkImpl extends CalendarSyncLink {
  _CalendarSyncLinkImpl({
    int? id,
    required int organizationId,
    required int taskId,
    required String externalEventId,
    DateTime? lastPushedAt,
    DateTime? lastPulledAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         taskId: taskId,
         externalEventId: externalEventId,
         lastPushedAt: lastPushedAt,
         lastPulledAt: lastPulledAt,
       );

  /// Returns a shallow copy of this [CalendarSyncLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CalendarSyncLink copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? taskId,
    String? externalEventId,
    Object? lastPushedAt = _Undefined,
    Object? lastPulledAt = _Undefined,
  }) {
    return CalendarSyncLink(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      taskId: taskId ?? this.taskId,
      externalEventId: externalEventId ?? this.externalEventId,
      lastPushedAt: lastPushedAt is DateTime?
          ? lastPushedAt
          : this.lastPushedAt,
      lastPulledAt: lastPulledAt is DateTime?
          ? lastPulledAt
          : this.lastPulledAt,
    );
  }
}
