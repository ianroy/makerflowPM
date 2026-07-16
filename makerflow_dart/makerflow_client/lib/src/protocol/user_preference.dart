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

/// Per-user UI/workflow settings (theme, timezone, locale, notifications,
/// session-timeout accommodation). Pinned in the local cache for offline.
abstract class UserPreference implements _i1.SerializableModel {
  UserPreference._({
    this.id,
    required this.userInfoId,
    String? theme,
    String? locale,
    this.timezone,
    this.notificationsJson,
    this.sessionTimeoutSeconds,
    this.uiJson,
    required this.updatedAt,
  }) : theme = theme ?? 'dark',
       locale = locale ?? 'en';

  factory UserPreference({
    int? id,
    required int userInfoId,
    String? theme,
    String? locale,
    String? timezone,
    String? notificationsJson,
    int? sessionTimeoutSeconds,
    String? uiJson,
    required DateTime updatedAt,
  }) = _UserPreferenceImpl;

  factory UserPreference.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserPreference(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int,
      theme: jsonSerialization['theme'] as String?,
      locale: jsonSerialization['locale'] as String?,
      timezone: jsonSerialization['timezone'] as String?,
      notificationsJson: jsonSerialization['notificationsJson'] as String?,
      sessionTimeoutSeconds: jsonSerialization['sessionTimeoutSeconds'] as int?,
      uiJson: jsonSerialization['uiJson'] as String?,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userInfoId;

  String theme;

  String locale;

  String? timezone;

  String? notificationsJson;

  int? sessionTimeoutSeconds;

  String? uiJson;

  DateTime updatedAt;

  /// Returns a shallow copy of this [UserPreference]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserPreference copyWith({
    int? id,
    int? userInfoId,
    String? theme,
    String? locale,
    String? timezone,
    String? notificationsJson,
    int? sessionTimeoutSeconds,
    String? uiJson,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserPreference',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      'theme': theme,
      'locale': locale,
      if (timezone != null) 'timezone': timezone,
      if (notificationsJson != null) 'notificationsJson': notificationsJson,
      if (sessionTimeoutSeconds != null)
        'sessionTimeoutSeconds': sessionTimeoutSeconds,
      if (uiJson != null) 'uiJson': uiJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserPreferenceImpl extends UserPreference {
  _UserPreferenceImpl({
    int? id,
    required int userInfoId,
    String? theme,
    String? locale,
    String? timezone,
    String? notificationsJson,
    int? sessionTimeoutSeconds,
    String? uiJson,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         userInfoId: userInfoId,
         theme: theme,
         locale: locale,
         timezone: timezone,
         notificationsJson: notificationsJson,
         sessionTimeoutSeconds: sessionTimeoutSeconds,
         uiJson: uiJson,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserPreference]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserPreference copyWith({
    Object? id = _Undefined,
    int? userInfoId,
    String? theme,
    String? locale,
    Object? timezone = _Undefined,
    Object? notificationsJson = _Undefined,
    Object? sessionTimeoutSeconds = _Undefined,
    Object? uiJson = _Undefined,
    DateTime? updatedAt,
  }) {
    return UserPreference(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      timezone: timezone is String? ? timezone : this.timezone,
      notificationsJson: notificationsJson is String?
          ? notificationsJson
          : this.notificationsJson,
      sessionTimeoutSeconds: sessionTimeoutSeconds is int?
          ? sessionTimeoutSeconds
          : this.sessionTimeoutSeconds,
      uiJson: uiJson is String? ? uiJson : this.uiJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
