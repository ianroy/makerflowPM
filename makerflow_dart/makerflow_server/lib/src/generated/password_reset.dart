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

/// Retained for parity/audit alongside serverpod_auth's own reset flow.
abstract class PasswordReset
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PasswordReset._({
    this.id,
    required this.userInfoId,
    required this.token,
    required this.expiresAt,
    this.usedAt,
    required this.createdAt,
  });

  factory PasswordReset({
    int? id,
    required int userInfoId,
    required String token,
    required DateTime expiresAt,
    DateTime? usedAt,
    required DateTime createdAt,
  }) = _PasswordResetImpl;

  factory PasswordReset.fromJson(Map<String, dynamic> jsonSerialization) {
    return PasswordReset(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int,
      token: jsonSerialization['token'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = PasswordResetTable();

  static const db = PasswordResetRepository._();

  @override
  int? id;

  int userInfoId;

  String token;

  DateTime expiresAt;

  DateTime? usedAt;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PasswordReset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PasswordReset copyWith({
    int? id,
    int? userInfoId,
    String? token,
    DateTime? expiresAt,
    DateTime? usedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PasswordReset',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      'token': token,
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PasswordReset',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      'token': token,
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static PasswordResetInclude include() {
    return PasswordResetInclude._();
  }

  static PasswordResetIncludeList includeList({
    _i1.WhereExpressionBuilder<PasswordResetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PasswordResetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PasswordResetTable>? orderByList,
    PasswordResetInclude? include,
  }) {
    return PasswordResetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PasswordReset.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PasswordReset.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PasswordResetImpl extends PasswordReset {
  _PasswordResetImpl({
    int? id,
    required int userInfoId,
    required String token,
    required DateTime expiresAt,
    DateTime? usedAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userInfoId: userInfoId,
         token: token,
         expiresAt: expiresAt,
         usedAt: usedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [PasswordReset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PasswordReset copyWith({
    Object? id = _Undefined,
    int? userInfoId,
    String? token,
    DateTime? expiresAt,
    Object? usedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return PasswordReset(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is DateTime? ? usedAt : this.usedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PasswordResetUpdateTable extends _i1.UpdateTable<PasswordResetTable> {
  PasswordResetUpdateTable(super.table);

  _i1.ColumnValue<int, int> userInfoId(int value) => _i1.ColumnValue(
    table.userInfoId,
    value,
  );

  _i1.ColumnValue<String, String> token(String value) => _i1.ColumnValue(
    table.token,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> usedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.usedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class PasswordResetTable extends _i1.Table<int?> {
  PasswordResetTable({super.tableRelation})
    : super(tableName: 'password_reset') {
    updateTable = PasswordResetUpdateTable(this);
    userInfoId = _i1.ColumnInt(
      'userInfoId',
      this,
    );
    token = _i1.ColumnString(
      'token',
      this,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
    usedAt = _i1.ColumnDateTime(
      'usedAt',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final PasswordResetUpdateTable updateTable;

  late final _i1.ColumnInt userInfoId;

  late final _i1.ColumnString token;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnDateTime usedAt;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userInfoId,
    token,
    expiresAt,
    usedAt,
    createdAt,
  ];
}

class PasswordResetInclude extends _i1.IncludeObject {
  PasswordResetInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PasswordReset.t;
}

class PasswordResetIncludeList extends _i1.IncludeList {
  PasswordResetIncludeList._({
    _i1.WhereExpressionBuilder<PasswordResetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PasswordReset.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PasswordReset.t;
}

class PasswordResetRepository {
  const PasswordResetRepository._();

  /// Returns a list of [PasswordReset]s matching the given query parameters.
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
  Future<List<PasswordReset>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PasswordResetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PasswordResetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PasswordResetTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PasswordReset>(
      where: where?.call(PasswordReset.t),
      orderBy: orderBy?.call(PasswordReset.t),
      orderByList: orderByList?.call(PasswordReset.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PasswordReset] matching the given query parameters.
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
  Future<PasswordReset?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PasswordResetTable>? where,
    int? offset,
    _i1.OrderByBuilder<PasswordResetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PasswordResetTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PasswordReset>(
      where: where?.call(PasswordReset.t),
      orderBy: orderBy?.call(PasswordReset.t),
      orderByList: orderByList?.call(PasswordReset.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PasswordReset] by its [id] or null if no such row exists.
  Future<PasswordReset?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PasswordReset>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PasswordReset]s in the list and returns the inserted rows.
  ///
  /// The returned [PasswordReset]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PasswordReset>> insert(
    _i1.DatabaseSession session,
    List<PasswordReset> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PasswordReset>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PasswordReset] and returns the inserted row.
  ///
  /// The returned [PasswordReset] will have its `id` field set.
  Future<PasswordReset> insertRow(
    _i1.DatabaseSession session,
    PasswordReset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PasswordReset>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PasswordReset]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PasswordReset>> update(
    _i1.DatabaseSession session,
    List<PasswordReset> rows, {
    _i1.ColumnSelections<PasswordResetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PasswordReset>(
      rows,
      columns: columns?.call(PasswordReset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PasswordReset]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PasswordReset> updateRow(
    _i1.DatabaseSession session,
    PasswordReset row, {
    _i1.ColumnSelections<PasswordResetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PasswordReset>(
      row,
      columns: columns?.call(PasswordReset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PasswordReset] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PasswordReset?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PasswordResetUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PasswordReset>(
      id,
      columnValues: columnValues(PasswordReset.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PasswordReset]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PasswordReset>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PasswordResetUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PasswordResetTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PasswordResetTable>? orderBy,
    _i1.OrderByListBuilder<PasswordResetTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PasswordReset>(
      columnValues: columnValues(PasswordReset.t.updateTable),
      where: where(PasswordReset.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PasswordReset.t),
      orderByList: orderByList?.call(PasswordReset.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PasswordReset]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PasswordReset>> delete(
    _i1.DatabaseSession session,
    List<PasswordReset> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PasswordReset>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PasswordReset].
  Future<PasswordReset> deleteRow(
    _i1.DatabaseSession session,
    PasswordReset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PasswordReset>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PasswordReset>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PasswordResetTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PasswordReset>(
      where: where(PasswordReset.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PasswordResetTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PasswordReset>(
      where: where?.call(PasswordReset.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PasswordReset] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PasswordResetTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PasswordReset>(
      where: where(PasswordReset.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
