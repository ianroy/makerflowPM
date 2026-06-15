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

/// Last-applied server change per device (fl-5-offline-sync). The client
/// advances this as it pulls deltas; the server uses it to compute what's new.
abstract class SyncCursor implements _i1.SerializableModel {
  SyncCursor._({
    this.id,
    required this.organizationId,
    required this.userInfoId,
    required this.deviceId,
    required this.lastUpdatedAt,
    int? lastId,
    required this.updatedAt,
  }) : lastId = lastId ?? 0;

  factory SyncCursor({
    int? id,
    required int organizationId,
    required int userInfoId,
    required String deviceId,
    required DateTime lastUpdatedAt,
    int? lastId,
    required DateTime updatedAt,
  }) = _SyncCursorImpl;

  factory SyncCursor.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncCursor(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      userInfoId: jsonSerialization['userInfoId'] as int,
      deviceId: jsonSerialization['deviceId'] as String,
      lastUpdatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastUpdatedAt'],
      ),
      lastId: jsonSerialization['lastId'] as int?,
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

  String deviceId;

  DateTime lastUpdatedAt;

  int lastId;

  DateTime updatedAt;

  /// Returns a shallow copy of this [SyncCursor]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SyncCursor copyWith({
    int? id,
    int? organizationId,
    int? userInfoId,
    String? deviceId,
    DateTime? lastUpdatedAt,
    int? lastId,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncCursor',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'userInfoId': userInfoId,
      'deviceId': deviceId,
      'lastUpdatedAt': lastUpdatedAt.toJson(),
      'lastId': lastId,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncCursorImpl extends SyncCursor {
  _SyncCursorImpl({
    int? id,
    required int organizationId,
    required int userInfoId,
    required String deviceId,
    required DateTime lastUpdatedAt,
    int? lastId,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         userInfoId: userInfoId,
         deviceId: deviceId,
         lastUpdatedAt: lastUpdatedAt,
         lastId: lastId,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SyncCursor]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SyncCursor copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? userInfoId,
    String? deviceId,
    DateTime? lastUpdatedAt,
    int? lastId,
    DateTime? updatedAt,
  }) {
    return SyncCursor(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      userInfoId: userInfoId ?? this.userInfoId,
      deviceId: deviceId ?? this.deviceId,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      lastId: lastId ?? this.lastId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
