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

/// Follow/subscribe on any entity. Drives push fan-out (fl-5-push).
abstract class ItemWatcher
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = ItemWatcherTable();

  static const db = ItemWatcherRepository._();

  @override
  int? id;

  int organizationId;

  String entityType;

  int entityId;

  int userInfoId;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static ItemWatcherInclude include() {
    return ItemWatcherInclude._();
  }

  static ItemWatcherIncludeList includeList({
    _i1.WhereExpressionBuilder<ItemWatcherTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ItemWatcherTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ItemWatcherTable>? orderByList,
    ItemWatcherInclude? include,
  }) {
    return ItemWatcherIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ItemWatcher.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ItemWatcher.t),
      include: include,
    );
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

class ItemWatcherUpdateTable extends _i1.UpdateTable<ItemWatcherTable> {
  ItemWatcherUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> entityType(String value) => _i1.ColumnValue(
    table.entityType,
    value,
  );

  _i1.ColumnValue<int, int> entityId(int value) => _i1.ColumnValue(
    table.entityId,
    value,
  );

  _i1.ColumnValue<int, int> userInfoId(int value) => _i1.ColumnValue(
    table.userInfoId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ItemWatcherTable extends _i1.Table<int?> {
  ItemWatcherTable({super.tableRelation}) : super(tableName: 'item_watcher') {
    updateTable = ItemWatcherUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    entityType = _i1.ColumnString(
      'entityType',
      this,
    );
    entityId = _i1.ColumnInt(
      'entityId',
      this,
    );
    userInfoId = _i1.ColumnInt(
      'userInfoId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ItemWatcherUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString entityType;

  late final _i1.ColumnInt entityId;

  late final _i1.ColumnInt userInfoId;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    entityType,
    entityId,
    userInfoId,
    createdAt,
  ];
}

class ItemWatcherInclude extends _i1.IncludeObject {
  ItemWatcherInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ItemWatcher.t;
}

class ItemWatcherIncludeList extends _i1.IncludeList {
  ItemWatcherIncludeList._({
    _i1.WhereExpressionBuilder<ItemWatcherTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ItemWatcher.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ItemWatcher.t;
}

class ItemWatcherRepository {
  const ItemWatcherRepository._();

  /// Returns a list of [ItemWatcher]s matching the given query parameters.
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
  Future<List<ItemWatcher>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ItemWatcherTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ItemWatcherTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ItemWatcherTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ItemWatcher>(
      where: where?.call(ItemWatcher.t),
      orderBy: orderBy?.call(ItemWatcher.t),
      orderByList: orderByList?.call(ItemWatcher.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ItemWatcher] matching the given query parameters.
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
  Future<ItemWatcher?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ItemWatcherTable>? where,
    int? offset,
    _i1.OrderByBuilder<ItemWatcherTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ItemWatcherTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ItemWatcher>(
      where: where?.call(ItemWatcher.t),
      orderBy: orderBy?.call(ItemWatcher.t),
      orderByList: orderByList?.call(ItemWatcher.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ItemWatcher] by its [id] or null if no such row exists.
  Future<ItemWatcher?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ItemWatcher>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ItemWatcher]s in the list and returns the inserted rows.
  ///
  /// The returned [ItemWatcher]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ItemWatcher>> insert(
    _i1.DatabaseSession session,
    List<ItemWatcher> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ItemWatcher>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ItemWatcher] and returns the inserted row.
  ///
  /// The returned [ItemWatcher] will have its `id` field set.
  Future<ItemWatcher> insertRow(
    _i1.DatabaseSession session,
    ItemWatcher row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ItemWatcher>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ItemWatcher]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ItemWatcher>> update(
    _i1.DatabaseSession session,
    List<ItemWatcher> rows, {
    _i1.ColumnSelections<ItemWatcherTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ItemWatcher>(
      rows,
      columns: columns?.call(ItemWatcher.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ItemWatcher]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ItemWatcher> updateRow(
    _i1.DatabaseSession session,
    ItemWatcher row, {
    _i1.ColumnSelections<ItemWatcherTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ItemWatcher>(
      row,
      columns: columns?.call(ItemWatcher.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ItemWatcher] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ItemWatcher?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ItemWatcherUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ItemWatcher>(
      id,
      columnValues: columnValues(ItemWatcher.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ItemWatcher]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ItemWatcher>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ItemWatcherUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ItemWatcherTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ItemWatcherTable>? orderBy,
    _i1.OrderByListBuilder<ItemWatcherTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ItemWatcher>(
      columnValues: columnValues(ItemWatcher.t.updateTable),
      where: where(ItemWatcher.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ItemWatcher.t),
      orderByList: orderByList?.call(ItemWatcher.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ItemWatcher]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ItemWatcher>> delete(
    _i1.DatabaseSession session,
    List<ItemWatcher> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ItemWatcher>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ItemWatcher].
  Future<ItemWatcher> deleteRow(
    _i1.DatabaseSession session,
    ItemWatcher row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ItemWatcher>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ItemWatcher>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ItemWatcherTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ItemWatcher>(
      where: where(ItemWatcher.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ItemWatcherTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ItemWatcher>(
      where: where?.call(ItemWatcher.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ItemWatcher] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ItemWatcherTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ItemWatcher>(
      where: where(ItemWatcher.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
