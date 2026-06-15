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

/// Follow/subscribe on any entity. Drives push fan-out (fl-5-push).
abstract class ItemWatcher implements _i1.SerializableModel {
  ItemWatcher._({
    this.id,
    required this.organizationId,
    required this.entityType,
    required this.entityId,
    required this.userInfoId,
    required this.createdAt,
  });

  factory ItemWatcher({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    required int userInfoId,
    required DateTime createdAt,
  }) = _ItemWatcherImpl;

  factory ItemWatcher.fromJson(Map<String, dynamic> jsonSerialization) {
    return ItemWatcher(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as int,
      userInfoId: jsonSerialization['userInfoId'] as int,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  String entityType;

  int entityId;

  int userInfoId;

  DateTime createdAt;

  /// Returns a shallow copy of this [ItemWatcher]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ItemWatcher copyWith({
    int? id,
    int? organizationId,
    String? entityType,
    int? entityId,
    int? userInfoId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ItemWatcher',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'entityId': entityId,
      'userInfoId': userInfoId,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ItemWatcherImpl extends ItemWatcher {
  _ItemWatcherImpl({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    required int userInfoId,
    required DateTime createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         entityType: entityType,
         entityId: entityId,
         userInfoId: userInfoId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ItemWatcher]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ItemWatcher copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? entityType,
    int? entityId,
    int? userInfoId,
    DateTime? createdAt,
  }) {
    return ItemWatcher(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      userInfoId: userInfoId ?? this.userInfoId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
