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
import 'enums/task_status.dart' as _i2;
import 'enums/task_priority.dart' as _i3;

/// Execution item. The `version` field supports offline conflict reconcile
/// (fl-5-offline-sync). Org-scoped, soft-deletable, audited.
abstract class Task implements _i1.SerializableModel {
  Task._({
    this.id,
    required this.organizationId,
    this.projectId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assigneeUserInfoId,
    this.reporterUserInfoId,
    this.energy,
    this.estimateHours,
    this.dueAt,
    this.spaceId,
    this.teamId,
    double? sortOrder,
    this.customFieldsJson,
    int? version,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : sortOrder = sortOrder ?? 0.0,
       version = version ?? 1;

  factory Task({
    int? id,
    required int organizationId,
    int? projectId,
    required String title,
    String? description,
    required _i2.TaskStatus status,
    required _i3.TaskPriority priority,
    int? assigneeUserInfoId,
    int? reporterUserInfoId,
    String? energy,
    double? estimateHours,
    DateTime? dueAt,
    int? spaceId,
    int? teamId,
    double? sortOrder,
    String? customFieldsJson,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _TaskImpl;

  factory Task.fromJson(Map<String, dynamic> jsonSerialization) {
    return Task(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      projectId: jsonSerialization['projectId'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      status: _i2.TaskStatus.fromJson((jsonSerialization['status'] as String)),
      priority: _i3.TaskPriority.fromJson(
        (jsonSerialization['priority'] as String),
      ),
      assigneeUserInfoId: jsonSerialization['assigneeUserInfoId'] as int?,
      reporterUserInfoId: jsonSerialization['reporterUserInfoId'] as int?,
      energy: jsonSerialization['energy'] as String?,
      estimateHours: (jsonSerialization['estimateHours'] as num?)?.toDouble(),
      dueAt: jsonSerialization['dueAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      spaceId: jsonSerialization['spaceId'] as int?,
      teamId: jsonSerialization['teamId'] as int?,
      sortOrder: (jsonSerialization['sortOrder'] as num?)?.toDouble(),
      customFieldsJson: jsonSerialization['customFieldsJson'] as String?,
      version: jsonSerialization['version'] as int?,
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

  int? projectId;

  String title;

  String? description;

  _i2.TaskStatus status;

  _i3.TaskPriority priority;

  int? assigneeUserInfoId;

  int? reporterUserInfoId;

  String? energy;

  double? estimateHours;

  DateTime? dueAt;

  int? spaceId;

  int? teamId;

  double sortOrder;

  String? customFieldsJson;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Task copyWith({
    int? id,
    int? organizationId,
    int? projectId,
    String? title,
    String? description,
    _i2.TaskStatus? status,
    _i3.TaskPriority? priority,
    int? assigneeUserInfoId,
    int? reporterUserInfoId,
    String? energy,
    double? estimateHours,
    DateTime? dueAt,
    int? spaceId,
    int? teamId,
    double? sortOrder,
    String? customFieldsJson,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Task',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      if (projectId != null) 'projectId': projectId,
      'title': title,
      if (description != null) 'description': description,
      'status': status.toJson(),
      'priority': priority.toJson(),
      if (assigneeUserInfoId != null) 'assigneeUserInfoId': assigneeUserInfoId,
      if (reporterUserInfoId != null) 'reporterUserInfoId': reporterUserInfoId,
      if (energy != null) 'energy': energy,
      if (estimateHours != null) 'estimateHours': estimateHours,
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      if (teamId != null) 'teamId': teamId,
      'sortOrder': sortOrder,
      if (customFieldsJson != null) 'customFieldsJson': customFieldsJson,
      'version': version,
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

class _TaskImpl extends Task {
  _TaskImpl({
    int? id,
    required int organizationId,
    int? projectId,
    required String title,
    String? description,
    required _i2.TaskStatus status,
    required _i3.TaskPriority priority,
    int? assigneeUserInfoId,
    int? reporterUserInfoId,
    String? energy,
    double? estimateHours,
    DateTime? dueAt,
    int? spaceId,
    int? teamId,
    double? sortOrder,
    String? customFieldsJson,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         projectId: projectId,
         title: title,
         description: description,
         status: status,
         priority: priority,
         assigneeUserInfoId: assigneeUserInfoId,
         reporterUserInfoId: reporterUserInfoId,
         energy: energy,
         estimateHours: estimateHours,
         dueAt: dueAt,
         spaceId: spaceId,
         teamId: teamId,
         sortOrder: sortOrder,
         customFieldsJson: customFieldsJson,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Task copyWith({
    Object? id = _Undefined,
    int? organizationId,
    Object? projectId = _Undefined,
    String? title,
    Object? description = _Undefined,
    _i2.TaskStatus? status,
    _i3.TaskPriority? priority,
    Object? assigneeUserInfoId = _Undefined,
    Object? reporterUserInfoId = _Undefined,
    Object? energy = _Undefined,
    Object? estimateHours = _Undefined,
    Object? dueAt = _Undefined,
    Object? spaceId = _Undefined,
    Object? teamId = _Undefined,
    double? sortOrder,
    Object? customFieldsJson = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return Task(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      projectId: projectId is int? ? projectId : this.projectId,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeUserInfoId: assigneeUserInfoId is int?
          ? assigneeUserInfoId
          : this.assigneeUserInfoId,
      reporterUserInfoId: reporterUserInfoId is int?
          ? reporterUserInfoId
          : this.reporterUserInfoId,
      energy: energy is String? ? energy : this.energy,
      estimateHours: estimateHours is double?
          ? estimateHours
          : this.estimateHours,
      dueAt: dueAt is DateTime? ? dueAt : this.dueAt,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
      teamId: teamId is int? ? teamId : this.teamId,
      sortOrder: sortOrder ?? this.sortOrder,
      customFieldsJson: customFieldsJson is String?
          ? customFieldsJson
          : this.customFieldsJson,
      version: version ?? this.version,
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
