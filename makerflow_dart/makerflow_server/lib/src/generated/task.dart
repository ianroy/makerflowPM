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
import 'package:serverpod/serverpod.dart' as _i1;
import 'enums/task_status.dart' as _i2;
import 'enums/task_priority.dart' as _i3;

/// Execution item. The `version` field supports offline conflict reconcile
/// (fl-5-offline-sync). Org-scoped, soft-deletable, audited.
abstract class Task implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = TaskTable();

  static const db = TaskRepository._();

  @override
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

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static TaskInclude include() {
    return TaskInclude._();
  }

  static TaskIncludeList includeList({
    _i1.WhereExpressionBuilder<TaskTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TaskTable>? orderByList,
    TaskInclude? include,
  }) {
    return TaskIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Task.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Task.t),
      include: include,
    );
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

class TaskUpdateTable extends _i1.UpdateTable<TaskTable> {
  TaskUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<int, int> projectId(int? value) => _i1.ColumnValue(
    table.projectId,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<_i2.TaskStatus, _i2.TaskStatus> status(
    _i2.TaskStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<_i3.TaskPriority, _i3.TaskPriority> priority(
    _i3.TaskPriority value,
  ) => _i1.ColumnValue(
    table.priority,
    value,
  );

  _i1.ColumnValue<int, int> assigneeUserInfoId(int? value) => _i1.ColumnValue(
    table.assigneeUserInfoId,
    value,
  );

  _i1.ColumnValue<int, int> reporterUserInfoId(int? value) => _i1.ColumnValue(
    table.reporterUserInfoId,
    value,
  );

  _i1.ColumnValue<String, String> energy(String? value) => _i1.ColumnValue(
    table.energy,
    value,
  );

  _i1.ColumnValue<double, double> estimateHours(double? value) =>
      _i1.ColumnValue(
        table.estimateHours,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> dueAt(DateTime? value) => _i1.ColumnValue(
    table.dueAt,
    value,
  );

  _i1.ColumnValue<int, int> spaceId(int? value) => _i1.ColumnValue(
    table.spaceId,
    value,
  );

  _i1.ColumnValue<int, int> teamId(int? value) => _i1.ColumnValue(
    table.teamId,
    value,
  );

  _i1.ColumnValue<double, double> sortOrder(double value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<int, int> version(int value) => _i1.ColumnValue(
    table.version,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );

  _i1.ColumnValue<int, int> createdByUserInfoId(int? value) => _i1.ColumnValue(
    table.createdByUserInfoId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.deletedAt,
        value,
      );

  _i1.ColumnValue<int, int> deletedByUserInfoId(int? value) => _i1.ColumnValue(
    table.deletedByUserInfoId,
    value,
  );
}

class TaskTable extends _i1.Table<int?> {
  TaskTable({super.tableRelation}) : super(tableName: 'task') {
    updateTable = TaskUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    projectId = _i1.ColumnInt(
      'projectId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
    );
    priority = _i1.ColumnEnum(
      'priority',
      this,
      _i1.EnumSerialization.byName,
    );
    assigneeUserInfoId = _i1.ColumnInt(
      'assigneeUserInfoId',
      this,
    );
    reporterUserInfoId = _i1.ColumnInt(
      'reporterUserInfoId',
      this,
    );
    energy = _i1.ColumnString(
      'energy',
      this,
    );
    estimateHours = _i1.ColumnDouble(
      'estimateHours',
      this,
    );
    dueAt = _i1.ColumnDateTime(
      'dueAt',
      this,
    );
    spaceId = _i1.ColumnInt(
      'spaceId',
      this,
    );
    teamId = _i1.ColumnInt(
      'teamId',
      this,
    );
    sortOrder = _i1.ColumnDouble(
      'sortOrder',
      this,
      hasDefault: true,
    );
    version = _i1.ColumnInt(
      'version',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
    createdByUserInfoId = _i1.ColumnInt(
      'createdByUserInfoId',
      this,
    );
    deletedAt = _i1.ColumnDateTime(
      'deletedAt',
      this,
    );
    deletedByUserInfoId = _i1.ColumnInt(
      'deletedByUserInfoId',
      this,
    );
  }

  late final TaskUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnInt projectId;

  late final _i1.ColumnString title;

  late final _i1.ColumnString description;

  late final _i1.ColumnEnum<_i2.TaskStatus> status;

  late final _i1.ColumnEnum<_i3.TaskPriority> priority;

  late final _i1.ColumnInt assigneeUserInfoId;

  late final _i1.ColumnInt reporterUserInfoId;

  late final _i1.ColumnString energy;

  late final _i1.ColumnDouble estimateHours;

  late final _i1.ColumnDateTime dueAt;

  late final _i1.ColumnInt spaceId;

  late final _i1.ColumnInt teamId;

  late final _i1.ColumnDouble sortOrder;

  late final _i1.ColumnInt version;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnInt createdByUserInfoId;

  late final _i1.ColumnDateTime deletedAt;

  late final _i1.ColumnInt deletedByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    projectId,
    title,
    description,
    status,
    priority,
    assigneeUserInfoId,
    reporterUserInfoId,
    energy,
    estimateHours,
    dueAt,
    spaceId,
    teamId,
    sortOrder,
    version,
    createdAt,
    updatedAt,
    createdByUserInfoId,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class TaskInclude extends _i1.IncludeObject {
  TaskInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Task.t;
}

class TaskIncludeList extends _i1.IncludeList {
  TaskIncludeList._({
    _i1.WhereExpressionBuilder<TaskTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Task.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Task.t;
}

class TaskRepository {
  const TaskRepository._();

  /// Returns a list of [Task]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Task>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TaskTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TaskTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Task>(
      where: where?.call(Task.t),
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Task] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Task?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TaskTable>? where,
    int? offset,
    _i1.OrderByBuilder<TaskTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<TaskTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Task>(
      where: where?.call(Task.t),
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Task] by its [id] or null if no such row exists.
  Future<Task?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Task>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Task]s in the list and returns the inserted rows.
  ///
  /// The returned [Task]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Task>> insert(
    _i1.DatabaseSession session,
    List<Task> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Task>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Task] and returns the inserted row.
  ///
  /// The returned [Task] will have its `id` field set.
  Future<Task> insertRow(
    _i1.DatabaseSession session,
    Task row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Task>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Task]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Task>> update(
    _i1.DatabaseSession session,
    List<Task> rows, {
    _i1.ColumnSelections<TaskTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Task>(
      rows,
      columns: columns?.call(Task.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Task]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Task> updateRow(
    _i1.DatabaseSession session,
    Task row, {
    _i1.ColumnSelections<TaskTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Task>(
      row,
      columns: columns?.call(Task.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Task] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Task?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<TaskUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Task>(
      id,
      columnValues: columnValues(Task.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Task]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Task>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<TaskUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<TaskTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<TaskTable>? orderBy,
    _i1.OrderByListBuilder<TaskTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Task>(
      columnValues: columnValues(Task.t.updateTable),
      where: where(Task.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Task.t),
      orderByList: orderByList?.call(Task.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Task]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Task>> delete(
    _i1.DatabaseSession session,
    List<Task> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Task>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Task].
  Future<Task> deleteRow(
    _i1.DatabaseSession session,
    Task row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Task>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Task>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<TaskTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Task>(
      where: where(Task.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<TaskTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Task>(
      where: where?.call(Task.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Task] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<TaskTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Task>(
      where: where(Task.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
