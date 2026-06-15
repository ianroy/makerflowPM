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

/// Profile extension keyed to a serverpod_auth UserInfo. serverpod_auth owns
/// the auth record (email, hash, scopes); this holds MakerFlow profile fields.
abstract class UserProfile implements _i1.SerializableModel {
  UserProfile._({
    this.id,
    required this.userInfoId,
    this.displayName,
    this.title,
    this.avatarAttachmentId,
    bool? isActive,
    required this.createdAt,
    required this.updatedAt,
  }) : isActive = isActive ?? true;

  factory UserProfile({
    int? id,
    required int userInfoId,
    String? displayName,
    String? title,
    int? avatarAttachmentId,
    bool? isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _UserProfileImpl;

  factory UserProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserProfile(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int,
      displayName: jsonSerialization['displayName'] as String?,
      title: jsonSerialization['title'] as String?,
      avatarAttachmentId: jsonSerialization['avatarAttachmentId'] as int?,
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
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

  int userInfoId;

  String? displayName;

  String? title;

  int? avatarAttachmentId;

  bool isActive;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserProfile copyWith({
    int? id,
    int? userInfoId,
    String? displayName,
    String? title,
    int? avatarAttachmentId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserProfile',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      if (displayName != null) 'displayName': displayName,
      if (title != null) 'title': title,
      if (avatarAttachmentId != null) 'avatarAttachmentId': avatarAttachmentId,
      'isActive': isActive,
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

class _UserProfileImpl extends UserProfile {
  _UserProfileImpl({
    int? id,
    required int userInfoId,
    String? displayName,
    String? title,
    int? avatarAttachmentId,
    bool? isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         userInfoId: userInfoId,
         displayName: displayName,
         title: title,
         avatarAttachmentId: avatarAttachmentId,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserProfile copyWith({
    Object? id = _Undefined,
    int? userInfoId,
    Object? displayName = _Undefined,
    Object? title = _Undefined,
    Object? avatarAttachmentId = _Undefined,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      displayName: displayName is String? ? displayName : this.displayName,
      title: title is String? ? title : this.title,
      avatarAttachmentId: avatarAttachmentId is int?
          ? avatarAttachmentId
          : this.avatarAttachmentId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
