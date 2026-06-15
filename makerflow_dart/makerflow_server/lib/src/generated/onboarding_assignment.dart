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
import 'enums/onboarding_state.dart' as _i2;

/// A template assigned to a person, with progress + completion.
abstract class OnboardingAssignment
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  OnboardingAssignment._({
    this.id,
    required this.organizationId,
    required this.templateId,
    required this.assigneeUserInfoId,
    _i2.OnboardingState? state,
    this.progressJson,
    this.dueAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : state = state ?? _i2.OnboardingState.notStarted;

  factory OnboardingAssignment({
    int? id,
    required int organizationId,
    required int templateId,
    required int assigneeUserInfoId,
    _i2.OnboardingState? state,
    String? progressJson,
    DateTime? dueAt,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OnboardingAssignmentImpl;

  factory OnboardingAssignment.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return OnboardingAssignment(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      templateId: jsonSerialization['templateId'] as int,
      assigneeUserInfoId: jsonSerialization['assigneeUserInfoId'] as int,
      state: jsonSerialization['state'] == null
          ? null
          : _i2.OnboardingState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      progressJson: jsonSerialization['progressJson'] as String?,
      dueAt: jsonSerialization['dueAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = OnboardingAssignmentTable();

  static const db = OnboardingAssignmentRepository._();

  @override
  int? id;

  int organizationId;

  int templateId;

  int assigneeUserInfoId;

  _i2.OnboardingState state;

  String? progressJson;

  DateTime? dueAt;

  DateTime? completedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [OnboardingAssignment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OnboardingAssignment copyWith({
    int? id,
    int? organizationId,
    int? templateId,
    int? assigneeUserInfoId,
    _i2.OnboardingState? state,
    String? progressJson,
    DateTime? dueAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OnboardingAssignment',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'templateId': templateId,
      'assigneeUserInfoId': assigneeUserInfoId,
      'state': state.toJson(),
      if (progressJson != null) 'progressJson': progressJson,
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'OnboardingAssignment',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'templateId': templateId,
      'assigneeUserInfoId': assigneeUserInfoId,
      'state': state.toJson(),
      if (progressJson != null) 'progressJson': progressJson,
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static OnboardingAssignmentInclude include() {
    return OnboardingAssignmentInclude._();
  }

  static OnboardingAssignmentIncludeList includeList({
    _i1.WhereExpressionBuilder<OnboardingAssignmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OnboardingAssignmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OnboardingAssignmentTable>? orderByList,
    OnboardingAssignmentInclude? include,
  }) {
    return OnboardingAssignmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OnboardingAssignment.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(OnboardingAssignment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OnboardingAssignmentImpl extends OnboardingAssignment {
  _OnboardingAssignmentImpl({
    int? id,
    required int organizationId,
    required int templateId,
    required int assigneeUserInfoId,
    _i2.OnboardingState? state,
    String? progressJson,
    DateTime? dueAt,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         templateId: templateId,
         assigneeUserInfoId: assigneeUserInfoId,
         state: state,
         progressJson: progressJson,
         dueAt: dueAt,
         completedAt: completedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [OnboardingAssignment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OnboardingAssignment copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? templateId,
    int? assigneeUserInfoId,
    _i2.OnboardingState? state,
    Object? progressJson = _Undefined,
    Object? dueAt = _Undefined,
    Object? completedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OnboardingAssignment(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      templateId: templateId ?? this.templateId,
      assigneeUserInfoId: assigneeUserInfoId ?? this.assigneeUserInfoId,
      state: state ?? this.state,
      progressJson: progressJson is String? ? progressJson : this.progressJson,
      dueAt: dueAt is DateTime? ? dueAt : this.dueAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OnboardingAssignmentUpdateTable
    extends _i1.UpdateTable<OnboardingAssignmentTable> {
  OnboardingAssignmentUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<int, int> templateId(int value) => _i1.ColumnValue(
    table.templateId,
    value,
  );

  _i1.ColumnValue<int, int> assigneeUserInfoId(int value) => _i1.ColumnValue(
    table.assigneeUserInfoId,
    value,
  );

  _i1.ColumnValue<_i2.OnboardingState, _i2.OnboardingState> state(
    _i2.OnboardingState value,
  ) => _i1.ColumnValue(
    table.state,
    value,
  );

  _i1.ColumnValue<String, String> progressJson(String? value) =>
      _i1.ColumnValue(
        table.progressJson,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> dueAt(DateTime? value) => _i1.ColumnValue(
    table.dueAt,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.completedAt,
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
}

class OnboardingAssignmentTable extends _i1.Table<int?> {
  OnboardingAssignmentTable({super.tableRelation})
    : super(tableName: 'onboarding_assignment') {
    updateTable = OnboardingAssignmentUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    templateId = _i1.ColumnInt(
      'templateId',
      this,
    );
    assigneeUserInfoId = _i1.ColumnInt(
      'assigneeUserInfoId',
      this,
    );
    state = _i1.ColumnEnum(
      'state',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    progressJson = _i1.ColumnString(
      'progressJson',
      this,
    );
    dueAt = _i1.ColumnDateTime(
      'dueAt',
      this,
    );
    completedAt = _i1.ColumnDateTime(
      'completedAt',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final OnboardingAssignmentUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnInt templateId;

  late final _i1.ColumnInt assigneeUserInfoId;

  late final _i1.ColumnEnum<_i2.OnboardingState> state;

  late final _i1.ColumnString progressJson;

  late final _i1.ColumnDateTime dueAt;

  late final _i1.ColumnDateTime completedAt;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    templateId,
    assigneeUserInfoId,
    state,
    progressJson,
    dueAt,
    completedAt,
    createdAt,
    updatedAt,
  ];
}

class OnboardingAssignmentInclude extends _i1.IncludeObject {
  OnboardingAssignmentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => OnboardingAssignment.t;
}

class OnboardingAssignmentIncludeList extends _i1.IncludeList {
  OnboardingAssignmentIncludeList._({
    _i1.WhereExpressionBuilder<OnboardingAssignmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OnboardingAssignment.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => OnboardingAssignment.t;
}

class OnboardingAssignmentRepository {
  const OnboardingAssignmentRepository._();

  /// Returns a list of [OnboardingAssignment]s matching the given query parameters.
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
  Future<List<OnboardingAssignment>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OnboardingAssignmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OnboardingAssignmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OnboardingAssignmentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OnboardingAssignment>(
      where: where?.call(OnboardingAssignment.t),
      orderBy: orderBy?.call(OnboardingAssignment.t),
      orderByList: orderByList?.call(OnboardingAssignment.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OnboardingAssignment] matching the given query parameters.
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
  Future<OnboardingAssignment?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OnboardingAssignmentTable>? where,
    int? offset,
    _i1.OrderByBuilder<OnboardingAssignmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OnboardingAssignmentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OnboardingAssignment>(
      where: where?.call(OnboardingAssignment.t),
      orderBy: orderBy?.call(OnboardingAssignment.t),
      orderByList: orderByList?.call(OnboardingAssignment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OnboardingAssignment] by its [id] or null if no such row exists.
  Future<OnboardingAssignment?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OnboardingAssignment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OnboardingAssignment]s in the list and returns the inserted rows.
  ///
  /// The returned [OnboardingAssignment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<OnboardingAssignment>> insert(
    _i1.DatabaseSession session,
    List<OnboardingAssignment> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<OnboardingAssignment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [OnboardingAssignment] and returns the inserted row.
  ///
  /// The returned [OnboardingAssignment] will have its `id` field set.
  Future<OnboardingAssignment> insertRow(
    _i1.DatabaseSession session,
    OnboardingAssignment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<OnboardingAssignment>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [OnboardingAssignment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<OnboardingAssignment>> update(
    _i1.DatabaseSession session,
    List<OnboardingAssignment> rows, {
    _i1.ColumnSelections<OnboardingAssignmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<OnboardingAssignment>(
      rows,
      columns: columns?.call(OnboardingAssignment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OnboardingAssignment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OnboardingAssignment> updateRow(
    _i1.DatabaseSession session,
    OnboardingAssignment row, {
    _i1.ColumnSelections<OnboardingAssignmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<OnboardingAssignment>(
      row,
      columns: columns?.call(OnboardingAssignment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OnboardingAssignment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OnboardingAssignment?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<OnboardingAssignmentUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<OnboardingAssignment>(
      id,
      columnValues: columnValues(OnboardingAssignment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OnboardingAssignment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<OnboardingAssignment>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<OnboardingAssignmentUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<OnboardingAssignmentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OnboardingAssignmentTable>? orderBy,
    _i1.OrderByListBuilder<OnboardingAssignmentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<OnboardingAssignment>(
      columnValues: columnValues(OnboardingAssignment.t.updateTable),
      where: where(OnboardingAssignment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OnboardingAssignment.t),
      orderByList: orderByList?.call(OnboardingAssignment.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [OnboardingAssignment]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<OnboardingAssignment>> delete(
    _i1.DatabaseSession session,
    List<OnboardingAssignment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<OnboardingAssignment>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [OnboardingAssignment].
  Future<OnboardingAssignment> deleteRow(
    _i1.DatabaseSession session,
    OnboardingAssignment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OnboardingAssignment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<OnboardingAssignment>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OnboardingAssignmentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<OnboardingAssignment>(
      where: where(OnboardingAssignment.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OnboardingAssignmentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<OnboardingAssignment>(
      where: where?.call(OnboardingAssignment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OnboardingAssignment] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OnboardingAssignmentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OnboardingAssignment>(
      where: where(OnboardingAssignment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
