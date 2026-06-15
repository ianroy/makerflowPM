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
import 'enums/task_priority.dart' as _i2;

/// Portfolio unit. Org-scoped, soft-deletable, audited.
abstract class Project implements _i1.SerializableModel {
  Project._({
    this.id,
    required this.organizationId,
    required this.name,
    this.lane,
    required this.status,
    required this.priority,
    this.ownerUserInfoId,
    this.teamId,
    this.spaceId,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  });

  factory Project({
    int? id,
    required int organizationId,
    required String name,
    String? lane,
    required String status,
    required _i2.TaskPriority priority,
    int? ownerUserInfoId,
    int? teamId,
    int? spaceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _ProjectImpl;

  factory Project.fromJson(Map<String, dynamic> jsonSerialization) {
    return Project(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      lane: jsonSerialization['lane'] as String?,
      status: jsonSerialization['status'] as String,
      priority: _i2.TaskPriority.fromJson(
        (jsonSerialization['priority'] as String),
      ),
      ownerUserInfoId: jsonSerialization['ownerUserInfoId'] as int?,
      teamId: jsonSerialization['teamId'] as int?,
      spaceId: jsonSerialization['spaceId'] as int?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      createdByUserInfoId: jsonSerialization['createdByUserInfoId'] as int?,
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

  String? lane;

  String status;

  _i2.TaskPriority priority;

  int? ownerUserInfoId;

  int? teamId;

  int? spaceId;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Project copyWith({
    int? id,
    int? organizationId,
    String? name,
    String? lane,
    String? status,
    _i2.TaskPriority? priority,
    int? ownerUserInfoId,
    int? teamId,
    int? spaceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Project',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (lane != null) 'lane': lane,
      'status': status,
      'priority': priority.toJson(),
      if (ownerUserInfoId != null) 'ownerUserInfoId': ownerUserInfoId,
      if (teamId != null) 'teamId': teamId,
      if (spaceId != null) 'spaceId': spaceId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
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

class _ProjectImpl extends Project {
  _ProjectImpl({
    int? id,
    required int organizationId,
    required String name,
    String? lane,
    required String status,
    required _i2.TaskPriority priority,
    int? ownerUserInfoId,
    int? teamId,
    int? spaceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         lane: lane,
         status: status,
         priority: priority,
         ownerUserInfoId: ownerUserInfoId,
         teamId: teamId,
         spaceId: spaceId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [Project]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Project copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    Object? lane = _Undefined,
    String? status,
    _i2.TaskPriority? priority,
    Object? ownerUserInfoId = _Undefined,
    Object? teamId = _Undefined,
    Object? spaceId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return Project(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      lane: lane is String? ? lane : this.lane,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      ownerUserInfoId: ownerUserInfoId is int?
          ? ownerUserInfoId
          : this.ownerUserInfoId,
      teamId: teamId is int? ? teamId : this.teamId,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdByUserInfoId: createdByUserInfoId is int?
          ? createdByUserInfoId
          : this.createdByUserInfoId,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByUserInfoId: deletedByUserInfoId is int?
          ? deletedByUserInfoId
          : this.deletedByUserInfoId,
    );
  }
}
