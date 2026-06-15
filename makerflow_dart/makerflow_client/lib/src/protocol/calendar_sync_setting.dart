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

/// Per-user Google Calendar OAuth + sync config. Secrets are encrypted at
/// rest (see Appendix G); never log token fields.
abstract class CalendarSyncSetting implements _i1.SerializableModel {
  CalendarSyncSetting._({
    this.id,
    required this.organizationId,
    required this.userInfoId,
    String? calendarId,
    this.refreshTokenEnc,
    bool? enabled,
    this.lastSyncedAt,
    required this.updatedAt,
  }) : calendarId = calendarId ?? 'primary',
       enabled = enabled ?? false;

  factory CalendarSyncSetting({
    int? id,
    required int organizationId,
    required int userInfoId,
    String? calendarId,
    String? refreshTokenEnc,
    bool? enabled,
    DateTime? lastSyncedAt,
    required DateTime updatedAt,
  }) = _CalendarSyncSettingImpl;

  factory CalendarSyncSetting.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarSyncSetting(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      userInfoId: jsonSerialization['userInfoId'] as int,
      calendarId: jsonSerialization['calendarId'] as String?,
      refreshTokenEnc: jsonSerialization['refreshTokenEnc'] as String?,
      enabled: jsonSerialization['enabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
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

  int userInfoId;

  String calendarId;

  String? refreshTokenEnc;

  bool enabled;

  DateTime? lastSyncedAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [CalendarSyncSetting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CalendarSyncSetting copyWith({
    int? id,
    int? organizationId,
    int? userInfoId,
    String? calendarId,
    String? refreshTokenEnc,
    bool? enabled,
    DateTime? lastSyncedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CalendarSyncSetting',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'userInfoId': userInfoId,
      'calendarId': calendarId,
      if (refreshTokenEnc != null) 'refreshTokenEnc': refreshTokenEnc,
      'enabled': enabled,
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSyncSettingImpl extends CalendarSyncSetting {
  _CalendarSyncSettingImpl({
    int? id,
    required int organizationId,
    required int userInfoId,
    String? calendarId,
    String? refreshTokenEnc,
    bool? enabled,
    DateTime? lastSyncedAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         userInfoId: userInfoId,
         calendarId: calendarId,
         refreshTokenEnc: refreshTokenEnc,
         enabled: enabled,
         lastSyncedAt: lastSyncedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarSyncSetting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CalendarSyncSetting copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? userInfoId,
    String? calendarId,
    Object? refreshTokenEnc = _Undefined,
    bool? enabled,
    Object? lastSyncedAt = _Undefined,
    DateTime? updatedAt,
  }) {
    return CalendarSyncSetting(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      userInfoId: userInfoId ?? this.userInfoId,
      calendarId: calendarId ?? this.calendarId,
      refreshTokenEnc: refreshTokenEnc is String?
          ? refreshTokenEnc
          : this.refreshTokenEnc,
      enabled: enabled ?? this.enabled,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
