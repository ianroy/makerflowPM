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

/// Retained for parity/audit alongside serverpod_auth's own reset flow.
abstract class PasswordReset implements _i1.SerializableModel {
  PasswordReset._({
    this.id,
    required this.userInfoId,
    required this.token,
    required this.expiresAt,
    this.usedAt,
    required this.createdAt,
  });

  factory PasswordReset({
    int? id,
    required int userInfoId,
    required String token,
    required DateTime expiresAt,
    DateTime? usedAt,
    required DateTime createdAt,
  }) = _PasswordResetImpl;

  factory PasswordReset.fromJson(Map<String, dynamic> jsonSerialization) {
    return PasswordReset(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int,
      token: jsonSerialization['token'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userInfoId;

  String token;

  DateTime expiresAt;

  DateTime? usedAt;

  DateTime createdAt;

  /// Returns a shallow copy of this [PasswordReset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PasswordReset copyWith({
    int? id,
    int? userInfoId,
    String? token,
    DateTime? expiresAt,
    DateTime? usedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PasswordReset',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      'token': token,
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PasswordResetImpl extends PasswordReset {
  _PasswordResetImpl({
    int? id,
    required int userInfoId,
    required String token,
    required DateTime expiresAt,
    DateTime? usedAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userInfoId: userInfoId,
         token: token,
         expiresAt: expiresAt,
         usedAt: usedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PasswordReset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PasswordReset copyWith({
    Object? id = _Undefined,
    int? userInfoId,
    String? token,
    DateTime? expiresAt,
    Object? usedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return PasswordReset(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is DateTime? ? usedAt : this.usedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
