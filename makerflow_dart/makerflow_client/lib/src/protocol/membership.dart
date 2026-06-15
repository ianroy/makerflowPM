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
import 'enums/membership_role.dart' as _i2;

/// Binds a serverpod_auth user to an organization with a role.
/// Non-superuser admins are pinned to ONE org (docs/DECISIONS.md). The
/// platform-level superuser flag lives on serverpod_auth's UserInfo scopes.
abstract class Membership implements _i1.SerializableModel {
  Membership._({
    this.id,
    required this.organizationId,
    required this.userInfoId,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Membership({
    int? id,
    required int organizationId,
    required int userInfoId,
    required _i2.MembershipRole role,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MembershipImpl;

  factory Membership.fromJson(Map<String, dynamic> jsonSerialization) {
    return Membership(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      userInfoId: jsonSerialization['userInfoId'] as int,
      role: _i2.MembershipRole.fromJson((jsonSerialization['role'] as String)),
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

  int userInfoId;

  _i2.MembershipRole role;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Membership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Membership copyWith({
    int? id,
    int? organizationId,
    int? userInfoId,
    _i2.MembershipRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Membership',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'userInfoId': userInfoId,
      'role': role.toJson(),
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

class _MembershipImpl extends Membership {
  _MembershipImpl({
    int? id,
    required int organizationId,
    required int userInfoId,
    required _i2.MembershipRole role,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         userInfoId: userInfoId,
         role: role,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Membership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Membership copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? userInfoId,
    _i2.MembershipRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Membership(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      userInfoId: userInfoId ?? this.userInfoId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
