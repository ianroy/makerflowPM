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

/// Saved filter/column set (per user, optionally shared). filtersJson and
/// columnsJson hold serialized config (the legacy custom_views payload).
abstract class CustomView implements _i1.SerializableModel {
  CustomView._({
    this.id,
    required this.organizationId,
    required this.ownerUserInfoId,
    required this.name,
    required this.entityType,
    required this.filtersJson,
    required this.columnsJson,
    bool? isShared,
    required this.createdAt,
    required this.updatedAt,
  }) : isShared = isShared ?? false;

  factory CustomView({
    int? id,
    required int organizationId,
    required int ownerUserInfoId,
    required String name,
    required String entityType,
    required String filtersJson,
    required String columnsJson,
    bool? isShared,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CustomViewImpl;

  factory CustomView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomView(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      ownerUserInfoId: jsonSerialization['ownerUserInfoId'] as int,
      name: jsonSerialization['name'] as String,
      entityType: jsonSerialization['entityType'] as String,
      filtersJson: jsonSerialization['filtersJson'] as String,
      columnsJson: jsonSerialization['columnsJson'] as String,
      isShared: jsonSerialization['isShared'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isShared']),
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

  int ownerUserInfoId;

  String name;

  String entityType;

  String filtersJson;

  String columnsJson;

  bool isShared;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [CustomView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CustomView copyWith({
    int? id,
    int? organizationId,
    int? ownerUserInfoId,
    String? name,
    String? entityType,
    String? filtersJson,
    String? columnsJson,
    bool? isShared,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomView',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'ownerUserInfoId': ownerUserInfoId,
      'name': name,
      'entityType': entityType,
      'filtersJson': filtersJson,
      'columnsJson': columnsJson,
      'isShared': isShared,
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

class _CustomViewImpl extends CustomView {
  _CustomViewImpl({
    int? id,
    required int organizationId,
    required int ownerUserInfoId,
    required String name,
    required String entityType,
    required String filtersJson,
    required String columnsJson,
    bool? isShared,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         ownerUserInfoId: ownerUserInfoId,
         name: name,
         entityType: entityType,
         filtersJson: filtersJson,
         columnsJson: columnsJson,
         isShared: isShared,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CustomView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CustomView copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? ownerUserInfoId,
    String? name,
    String? entityType,
    String? filtersJson,
    String? columnsJson,
    bool? isShared,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomView(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      ownerUserInfoId: ownerUserInfoId ?? this.ownerUserInfoId,
      name: name ?? this.name,
      entityType: entityType ?? this.entityType,
      filtersJson: filtersJson ?? this.filtersJson,
      columnsJson: columnsJson ?? this.columnsJson,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
