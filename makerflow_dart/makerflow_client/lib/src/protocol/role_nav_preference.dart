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

/// Per-role default sidebar/nav config for an org (legacy role_nav_preferences).
abstract class RoleNavPreference implements _i1.SerializableModel {
  RoleNavPreference._({
    this.id,
    required this.organizationId,
    required this.role,
    required this.navJson,
    required this.updatedAt,
  });

  factory RoleNavPreference({
    int? id,
    required int organizationId,
    required _i2.MembershipRole role,
    required String navJson,
    required DateTime updatedAt,
  }) = _RoleNavPreferenceImpl;

  factory RoleNavPreference.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoleNavPreference(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      role: _i2.MembershipRole.fromJson((jsonSerialization['role'] as String)),
      navJson: jsonSerialization['navJson'] as String,
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

  _i2.MembershipRole role;

  String navJson;

  DateTime updatedAt;

  /// Returns a shallow copy of this [RoleNavPreference]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RoleNavPreference copyWith({
    int? id,
    int? organizationId,
    _i2.MembershipRole? role,
    String? navJson,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoleNavPreference',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'role': role.toJson(),
      'navJson': navJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoleNavPreferenceImpl extends RoleNavPreference {
  _RoleNavPreferenceImpl({
    int? id,
    required int organizationId,
    required _i2.MembershipRole role,
    required String navJson,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         role: role,
         navJson: navJson,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RoleNavPreference]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RoleNavPreference copyWith({
    Object? id = _Undefined,
    int? organizationId,
    _i2.MembershipRole? role,
    String? navJson,
    DateTime? updatedAt,
  }) {
    return RoleNavPreference(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      role: role ?? this.role,
      navJson: navJson ?? this.navJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
