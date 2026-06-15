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

/// Bidirectional bridge between a MakerFlow task and a Google event.
abstract class CalendarSyncLink
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CalendarSyncLink._({
    this.id,
    required this.organizationId,
    required this.taskId,
    required this.externalEventId,
    this.lastPushedAt,
    this.lastPulledAt,
  });

  factory CalendarSyncLink({
    int? id,
    required int organizationId,
    required int taskId,
    required String externalEventId,
    DateTime? lastPushedAt,
    DateTime? lastPulledAt,
  }) = _CalendarSyncLinkImpl;

  factory CalendarSyncLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarSyncLink(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      taskId: jsonSerialization['taskId'] as int,
      externalEventId: jsonSerialization['externalEventId'] as String,
      lastPushedAt: jsonSerialization['lastPushedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastPushedAt'],
            ),
      lastPulledAt: jsonSerialization['lastPulledAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastPulledAt'],
            ),
    );
  }

  static final t = CalendarSyncLinkTable();

  static const db = CalendarSyncLinkRepository._();

  @override
  int? id;

  int organizationId;

  int taskId;

  String externalEventId;

  DateTime? lastPushedAt;

  DateTime? lastPulledAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarSyncLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CalendarSyncLink copyWith({
    int? id,
    int? organizationId,
    int? taskId,
    String? externalEventId,
    DateTime? lastPushedAt,
    DateTime? lastPulledAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CalendarSyncLink',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'taskId': taskId,
      'externalEventId': externalEventId,
      if (lastPushedAt != null) 'lastPushedAt': lastPushedAt?.toJson(),
      if (lastPulledAt != null) 'lastPulledAt': lastPulledAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CalendarSyncLink',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'taskId': taskId,
      'externalEventId': externalEventId,
      if (lastPushedAt != null) 'lastPushedAt': lastPushedAt?.toJson(),
      if (lastPulledAt != null) 'lastPulledAt': lastPulledAt?.toJson(),
    };
  }

  static CalendarSyncLinkInclude include() {
    return CalendarSyncLinkInclude._();
  }

  static CalendarSyncLinkIncludeList includeList({
    _i1.WhereExpressionBuilder<CalendarSyncLinkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CalendarSyncLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CalendarSyncLinkTable>? orderByList,
    CalendarSyncLinkInclude? include,
  }) {
    return CalendarSyncLinkIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSyncLink.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CalendarSyncLink.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSyncLinkImpl extends CalendarSyncLink {
  _CalendarSyncLinkImpl({
    int? id,
    required int organizationId,
    required int taskId,
    required String externalEventId,
    DateTime? lastPushedAt,
    DateTime? lastPulledAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         taskId: taskId,
         externalEventId: externalEventId,
         lastPushedAt: lastPushedAt,
         lastPulledAt: lastPulledAt,
       );

  /// Returns a shallow copy of this [CalendarSyncLink]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CalendarSyncLink copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? taskId,
    String? externalEventId,
    Object? lastPushedAt = _Undefined,
    Object? lastPulledAt = _Undefined,
  }) {
    return CalendarSyncLink(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      taskId: taskId ?? this.taskId,
      externalEventId: externalEventId ?? this.externalEventId,
      lastPushedAt: lastPushedAt is DateTime?
          ? lastPushedAt
          : this.lastPushedAt,
      lastPulledAt: lastPulledAt is DateTime?
          ? lastPulledAt
          : this.lastPulledAt,
    );
  }
}

class CalendarSyncLinkUpdateTable
    extends _i1.UpdateTable<CalendarSyncLinkTable> {
  CalendarSyncLinkUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<int, int> taskId(int value) => _i1.ColumnValue(
    table.taskId,
    value,
  );

  _i1.ColumnValue<String, String> externalEventId(String value) =>
      _i1.ColumnValue(
        table.externalEventId,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastPushedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastPushedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastPulledAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastPulledAt,
        value,
      );
}

class CalendarSyncLinkTable extends _i1.Table<int?> {
  CalendarSyncLinkTable({super.tableRelation})
    : super(tableName: 'calendar_sync_link') {
    updateTable = CalendarSyncLinkUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    taskId = _i1.ColumnInt(
      'taskId',
      this,
    );
    externalEventId = _i1.ColumnString(
      'externalEventId',
      this,
    );
    lastPushedAt = _i1.ColumnDateTime(
      'lastPushedAt',
      this,
    );
    lastPulledAt = _i1.ColumnDateTime(
      'lastPulledAt',
      this,
    );
  }

  late final CalendarSyncLinkUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnInt taskId;

  late final _i1.ColumnString externalEventId;

  late final _i1.ColumnDateTime lastPushedAt;

  late final _i1.ColumnDateTime lastPulledAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    taskId,
    externalEventId,
    lastPushedAt,
    lastPulledAt,
  ];
}

class CalendarSyncLinkInclude extends _i1.IncludeObject {
  CalendarSyncLinkInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CalendarSyncLink.t;
}

class CalendarSyncLinkIncludeList extends _i1.IncludeList {
  CalendarSyncLinkIncludeList._({
    _i1.WhereExpressionBuilder<CalendarSyncLinkTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSyncLink.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CalendarSyncLink.t;
}

class CalendarSyncLinkRepository {
  const CalendarSyncLinkRepository._();

  /// Returns a list of [CalendarSyncLink]s matching the given query parameters.
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
  Future<List<CalendarSyncLink>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CalendarSyncLinkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CalendarSyncLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CalendarSyncLinkTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSyncLink>(
      where: where?.call(CalendarSyncLink.t),
      orderBy: orderBy?.call(CalendarSyncLink.t),
      orderByList: orderByList?.call(CalendarSyncLink.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSyncLink] matching the given query parameters.
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
  Future<CalendarSyncLink?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CalendarSyncLinkTable>? where,
    int? offset,
    _i1.OrderByBuilder<CalendarSyncLinkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CalendarSyncLinkTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSyncLink>(
      where: where?.call(CalendarSyncLink.t),
      orderBy: orderBy?.call(CalendarSyncLink.t),
      orderByList: orderByList?.call(CalendarSyncLink.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSyncLink] by its [id] or null if no such row exists.
  Future<CalendarSyncLink?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSyncLink>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSyncLink]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSyncLink]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CalendarSyncLink>> insert(
    _i1.DatabaseSession session,
    List<CalendarSyncLink> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CalendarSyncLink>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CalendarSyncLink] and returns the inserted row.
  ///
  /// The returned [CalendarSyncLink] will have its `id` field set.
  Future<CalendarSyncLink> insertRow(
    _i1.DatabaseSession session,
    CalendarSyncLink row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSyncLink>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSyncLink]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CalendarSyncLink>> update(
    _i1.DatabaseSession session,
    List<CalendarSyncLink> rows, {
    _i1.ColumnSelections<CalendarSyncLinkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CalendarSyncLink>(
      rows,
      columns: columns?.call(CalendarSyncLink.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSyncLink]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSyncLink> updateRow(
    _i1.DatabaseSession session,
    CalendarSyncLink row, {
    _i1.ColumnSelections<CalendarSyncLinkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSyncLink>(
      row,
      columns: columns?.call(CalendarSyncLink.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSyncLink] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSyncLink?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CalendarSyncLinkUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSyncLink>(
      id,
      columnValues: columnValues(CalendarSyncLink.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSyncLink]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CalendarSyncLink>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CalendarSyncLinkUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<CalendarSyncLinkTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CalendarSyncLinkTable>? orderBy,
    _i1.OrderByListBuilder<CalendarSyncLinkTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CalendarSyncLink>(
      columnValues: columnValues(CalendarSyncLink.t.updateTable),
      where: where(CalendarSyncLink.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSyncLink.t),
      orderByList: orderByList?.call(CalendarSyncLink.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CalendarSyncLink]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CalendarSyncLink>> delete(
    _i1.DatabaseSession session,
    List<CalendarSyncLink> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CalendarSyncLink>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CalendarSyncLink].
  Future<CalendarSyncLink> deleteRow(
    _i1.DatabaseSession session,
    CalendarSyncLink row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSyncLink>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CalendarSyncLink>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CalendarSyncLinkTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CalendarSyncLink>(
      where: where(CalendarSyncLink.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CalendarSyncLinkTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSyncLink>(
      where: where?.call(CalendarSyncLink.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSyncLink] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CalendarSyncLinkTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSyncLink>(
      where: where(CalendarSyncLink.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
