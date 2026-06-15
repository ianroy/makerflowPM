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

/// Point-in-time aggregate seeded by the reports module.
abstract class InsightSnapshot
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  InsightSnapshot._({
    this.id,
    required this.organizationId,
    required this.metricKey,
    required this.value,
    required this.capturedAt,
    this.dimensionsJson,
  });

  factory InsightSnapshot({
    int? id,
    required int organizationId,
    required String metricKey,
    required double value,
    required DateTime capturedAt,
    String? dimensionsJson,
  }) = _InsightSnapshotImpl;

  factory InsightSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return InsightSnapshot(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      metricKey: jsonSerialization['metricKey'] as String,
      value: (jsonSerialization['value'] as num).toDouble(),
      capturedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['capturedAt'],
      ),
      dimensionsJson: jsonSerialization['dimensionsJson'] as String?,
    );
  }

  static final t = InsightSnapshotTable();

  static const db = InsightSnapshotRepository._();

  @override
  int? id;

  int organizationId;

  String metricKey;

  double value;

  DateTime capturedAt;

  String? dimensionsJson;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [InsightSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  InsightSnapshot copyWith({
    int? id,
    int? organizationId,
    String? metricKey,
    double? value,
    DateTime? capturedAt,
    String? dimensionsJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InsightSnapshot',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'metricKey': metricKey,
      'value': value,
      'capturedAt': capturedAt.toJson(),
      if (dimensionsJson != null) 'dimensionsJson': dimensionsJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InsightSnapshot',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'metricKey': metricKey,
      'value': value,
      'capturedAt': capturedAt.toJson(),
      if (dimensionsJson != null) 'dimensionsJson': dimensionsJson,
    };
  }

  static InsightSnapshotInclude include() {
    return InsightSnapshotInclude._();
  }

  static InsightSnapshotIncludeList includeList({
    _i1.WhereExpressionBuilder<InsightSnapshotTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InsightSnapshotTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InsightSnapshotTable>? orderByList,
    InsightSnapshotInclude? include,
  }) {
    return InsightSnapshotIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InsightSnapshot.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(InsightSnapshot.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InsightSnapshotImpl extends InsightSnapshot {
  _InsightSnapshotImpl({
    int? id,
    required int organizationId,
    required String metricKey,
    required double value,
    required DateTime capturedAt,
    String? dimensionsJson,
  }) : super._(
         id: id,
         organizationId: organizationId,
         metricKey: metricKey,
         value: value,
         capturedAt: capturedAt,
         dimensionsJson: dimensionsJson,
       );

  /// Returns a shallow copy of this [InsightSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  InsightSnapshot copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? metricKey,
    double? value,
    DateTime? capturedAt,
    Object? dimensionsJson = _Undefined,
  }) {
    return InsightSnapshot(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      metricKey: metricKey ?? this.metricKey,
      value: value ?? this.value,
      capturedAt: capturedAt ?? this.capturedAt,
      dimensionsJson: dimensionsJson is String?
          ? dimensionsJson
          : this.dimensionsJson,
    );
  }
}

class InsightSnapshotUpdateTable extends _i1.UpdateTable<InsightSnapshotTable> {
  InsightSnapshotUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> metricKey(String value) => _i1.ColumnValue(
    table.metricKey,
    value,
  );

  _i1.ColumnValue<double, double> value(double value) => _i1.ColumnValue(
    table.value,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> capturedAt(DateTime value) =>
      _i1.ColumnValue(
        table.capturedAt,
        value,
      );

  _i1.ColumnValue<String, String> dimensionsJson(String? value) =>
      _i1.ColumnValue(
        table.dimensionsJson,
        value,
      );
}

class InsightSnapshotTable extends _i1.Table<int?> {
  InsightSnapshotTable({super.tableRelation})
    : super(tableName: 'insight_snapshot') {
    updateTable = InsightSnapshotUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    metricKey = _i1.ColumnString(
      'metricKey',
      this,
    );
    value = _i1.ColumnDouble(
      'value',
      this,
    );
    capturedAt = _i1.ColumnDateTime(
      'capturedAt',
      this,
    );
    dimensionsJson = _i1.ColumnString(
      'dimensionsJson',
      this,
    );
  }

  late final InsightSnapshotUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString metricKey;

  late final _i1.ColumnDouble value;

  late final _i1.ColumnDateTime capturedAt;

  late final _i1.ColumnString dimensionsJson;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    metricKey,
    value,
    capturedAt,
    dimensionsJson,
  ];
}

class InsightSnapshotInclude extends _i1.IncludeObject {
  InsightSnapshotInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => InsightSnapshot.t;
}

class InsightSnapshotIncludeList extends _i1.IncludeList {
  InsightSnapshotIncludeList._({
    _i1.WhereExpressionBuilder<InsightSnapshotTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(InsightSnapshot.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => InsightSnapshot.t;
}

class InsightSnapshotRepository {
  const InsightSnapshotRepository._();

  /// Returns a list of [InsightSnapshot]s matching the given query parameters.
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
  Future<List<InsightSnapshot>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<InsightSnapshotTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InsightSnapshotTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InsightSnapshotTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<InsightSnapshot>(
      where: where?.call(InsightSnapshot.t),
      orderBy: orderBy?.call(InsightSnapshot.t),
      orderByList: orderByList?.call(InsightSnapshot.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [InsightSnapshot] matching the given query parameters.
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
  Future<InsightSnapshot?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<InsightSnapshotTable>? where,
    int? offset,
    _i1.OrderByBuilder<InsightSnapshotTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<InsightSnapshotTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<InsightSnapshot>(
      where: where?.call(InsightSnapshot.t),
      orderBy: orderBy?.call(InsightSnapshot.t),
      orderByList: orderByList?.call(InsightSnapshot.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [InsightSnapshot] by its [id] or null if no such row exists.
  Future<InsightSnapshot?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<InsightSnapshot>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [InsightSnapshot]s in the list and returns the inserted rows.
  ///
  /// The returned [InsightSnapshot]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<InsightSnapshot>> insert(
    _i1.DatabaseSession session,
    List<InsightSnapshot> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<InsightSnapshot>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [InsightSnapshot] and returns the inserted row.
  ///
  /// The returned [InsightSnapshot] will have its `id` field set.
  Future<InsightSnapshot> insertRow(
    _i1.DatabaseSession session,
    InsightSnapshot row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<InsightSnapshot>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [InsightSnapshot]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<InsightSnapshot>> update(
    _i1.DatabaseSession session,
    List<InsightSnapshot> rows, {
    _i1.ColumnSelections<InsightSnapshotTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<InsightSnapshot>(
      rows,
      columns: columns?.call(InsightSnapshot.t),
      transaction: transaction,
    );
  }

  /// Updates a single [InsightSnapshot]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<InsightSnapshot> updateRow(
    _i1.DatabaseSession session,
    InsightSnapshot row, {
    _i1.ColumnSelections<InsightSnapshotTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<InsightSnapshot>(
      row,
      columns: columns?.call(InsightSnapshot.t),
      transaction: transaction,
    );
  }

  /// Updates a single [InsightSnapshot] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<InsightSnapshot?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<InsightSnapshotUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<InsightSnapshot>(
      id,
      columnValues: columnValues(InsightSnapshot.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [InsightSnapshot]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<InsightSnapshot>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<InsightSnapshotUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<InsightSnapshotTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InsightSnapshotTable>? orderBy,
    _i1.OrderByListBuilder<InsightSnapshotTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<InsightSnapshot>(
      columnValues: columnValues(InsightSnapshot.t.updateTable),
      where: where(InsightSnapshot.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(InsightSnapshot.t),
      orderByList: orderByList?.call(InsightSnapshot.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [InsightSnapshot]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<InsightSnapshot>> delete(
    _i1.DatabaseSession session,
    List<InsightSnapshot> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<InsightSnapshot>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [InsightSnapshot].
  Future<InsightSnapshot> deleteRow(
    _i1.DatabaseSession session,
    InsightSnapshot row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<InsightSnapshot>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<InsightSnapshot>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<InsightSnapshotTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<InsightSnapshot>(
      where: where(InsightSnapshot.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<InsightSnapshotTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<InsightSnapshot>(
      where: where?.call(InsightSnapshot.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [InsightSnapshot] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<InsightSnapshotTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<InsightSnapshot>(
      where: where(InsightSnapshot.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
