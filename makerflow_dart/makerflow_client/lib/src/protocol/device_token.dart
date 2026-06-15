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

/// Push registry per user/device (fl-5-push). platform drives FCM vs APNs.
abstract class DeviceToken implements _i1.SerializableModel {
  DeviceToken._({
    this.id,
    required this.userInfoId,
    required this.token,
    required this.platform,
    required this.createdAt,
    this.lastSeenAt,
  });

  factory DeviceToken({
    int? id,
    required int userInfoId,
    required String token,
    required String platform,
    required DateTime createdAt,
    DateTime? lastSeenAt,
  }) = _DeviceTokenImpl;

  factory DeviceToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeviceToken(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int,
      token: jsonSerialization['token'] as String,
      platform: jsonSerialization['platform'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeenAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userInfoId;

  String token;

  String platform;

  DateTime createdAt;

  DateTime? lastSeenAt;

  /// Returns a shallow copy of this [DeviceToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeviceToken copyWith({
    int? id,
    int? userInfoId,
    String? token,
    String? platform,
    DateTime? createdAt,
    DateTime? lastSeenAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeviceToken',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      'token': token,
      'platform': platform,
      'createdAt': createdAt.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeviceTokenImpl extends DeviceToken {
  _DeviceTokenImpl({
    int? id,
    required int userInfoId,
    required String token,
    required String platform,
    required DateTime createdAt,
    DateTime? lastSeenAt,
  }) : super._(
         id: id,
         userInfoId: userInfoId,
         token: token,
         platform: platform,
         createdAt: createdAt,
         lastSeenAt: lastSeenAt,
       );

  /// Returns a shallow copy of this [DeviceToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeviceToken copyWith({
    Object? id = _Undefined,
    int? userInfoId,
    String? token,
    String? platform,
    DateTime? createdAt,
    Object? lastSeenAt = _Undefined,
  }) {
    return DeviceToken(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      token: token ?? this.token,
      platform: platform ?? this.platform,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt is DateTime? ? lastSeenAt : this.lastSeenAt,
    );
  }
}
