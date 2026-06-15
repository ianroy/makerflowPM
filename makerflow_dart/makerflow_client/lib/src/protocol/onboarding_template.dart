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

/// Role-based onboarding checklist. itemsJson holds the ordered steps.
abstract class OnboardingTemplate implements _i1.SerializableModel {
  OnboardingTemplate._({
    this.id,
    required this.organizationId,
    required this.name,
    this.forRole,
    required this.itemsJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserInfoId,
  });

  factory OnboardingTemplate({
    int? id,
    required int organizationId,
    required String name,
    _i2.MembershipRole? forRole,
    required String itemsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _OnboardingTemplateImpl;

  factory OnboardingTemplate.fromJson(Map<String, dynamic> jsonSerialization) {
    return OnboardingTemplate(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      forRole: jsonSerialization['forRole'] == null
          ? null
          : _i2.MembershipRole.fromJson(
              (jsonSerialization['forRole'] as String),
            ),
      itemsJson: jsonSerialization['itemsJson'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      deletedByUserInfoId: jsonSerialization['deletedByUserInfoId'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  String name;

  _i2.MembershipRole? forRole;

  String itemsJson;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [OnboardingTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OnboardingTemplate copyWith({
    int? id,
    int? organizationId,
    String? name,
    _i2.MembershipRole? forRole,
    String? itemsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OnboardingTemplate',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (forRole != null) 'forRole': forRole?.toJson(),
      'itemsJson': itemsJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OnboardingTemplateImpl extends OnboardingTemplate {
  _OnboardingTemplateImpl({
    int? id,
    required int organizationId,
    required String name,
    _i2.MembershipRole? forRole,
    required String itemsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         forRole: forRole,
         itemsJson: itemsJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [OnboardingTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OnboardingTemplate copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    Object? forRole = _Undefined,
    String? itemsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return OnboardingTemplate(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      forRole: forRole is _i2.MembershipRole? ? forRole : this.forRole,
      itemsJson: itemsJson ?? this.itemsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByUserInfoId: deletedByUserInfoId is int?
          ? deletedByUserInfoId
          : this.deletedByUserInfoId,
    );
  }
}
