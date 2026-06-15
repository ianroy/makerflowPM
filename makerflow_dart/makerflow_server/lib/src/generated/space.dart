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

/// Physical location within an organization.
abstract class Space implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Space._({
    this.id,
    required this.organizationId,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserInfoId,
  });

  factory Space({
    int? id,
    required int organizationId,
    required String name,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _SpaceImpl;

  factory Space.fromJson(Map<String, dynamic> jsonSerialization) {
    return Space(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      description: jsonSerialization['description'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      deletedByUserInfoId: jsonSerialization['deletedByUserInfoId'] as int?,
    );
  }

  static final t = SpaceTable();

  static const db = SpaceRepository._();

  @override
  int? id;

  int organizationId;

  String name;

  String? description;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Space]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Space copyWith({
    int? id,
    int? organizationId,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Space',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (description != null) 'description': description,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Space',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (description != null) 'description': description,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static SpaceInclude include() {
    return SpaceInclude._();
  }

  static SpaceIncludeList includeList({
    _i1.WhereExpressionBuilder<SpaceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SpaceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SpaceTable>? orderByList,
    SpaceInclude? include,
  }) {
    return SpaceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Space.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Space.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SpaceImpl extends Space {
  _SpaceImpl({
    int? id,
    required int organizationId,
    required String name,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         description: description,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [Space]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Space copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    Object? description = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return Space(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      description: description is String? ? description : this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByUserInfoId: deletedByUserInfoId is int?
          ? deletedByUserInfoId
          : this.deletedByUserInfoId,
    );
  }
}

class SpaceUpdateTable extends _i1.UpdateTable<SpaceTable> {
  SpaceUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
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

class SpaceTable extends _i1.Table<int?> {
  SpaceTable({super.tableRelation}) : super(tableName: 'space') {
    updateTable = SpaceUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    description = _i1.ColumnString(
      'description',
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
    deletedAt = _i1.ColumnDateTime(
      'deletedAt',
      this,
    );
    deletedByUserInfoId = _i1.ColumnInt(
      'deletedByUserInfoId',
      this,
    );
  }

  late final SpaceUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString description;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime deletedAt;

  late final _i1.ColumnInt deletedByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    name,
    description,
    createdAt,
    updatedAt,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class SpaceInclude extends _i1.IncludeObject {
  SpaceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Space.t;
}

class SpaceIncludeList extends _i1.IncludeList {
  SpaceIncludeList._({
    _i1.WhereExpressionBuilder<SpaceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Space.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Space.t;
}

class SpaceRepository {
  const SpaceRepository._();

  /// Returns a list of [Space]s matching the given query parameters.
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
  Future<List<Space>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SpaceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SpaceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SpaceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Space>(
      where: where?.call(Space.t),
      orderBy: orderBy?.call(Space.t),
      orderByList: orderByList?.call(Space.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Space] matching the given query parameters.
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
  Future<Space?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SpaceTable>? where,
    int? offset,
    _i1.OrderByBuilder<SpaceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SpaceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Space>(
      where: where?.call(Space.t),
      orderBy: orderBy?.call(Space.t),
      orderByList: orderByList?.call(Space.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Space] by its [id] or null if no such row exists.
  Future<Space?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Space>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Space]s in the list and returns the inserted rows.
  ///
  /// The returned [Space]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Space>> insert(
    _i1.DatabaseSession session,
    List<Space> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Space>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Space] and returns the inserted row.
  ///
  /// The returned [Space] will have its `id` field set.
  Future<Space> insertRow(
    _i1.DatabaseSession session,
    Space row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Space>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Space]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Space>> update(
    _i1.DatabaseSession session,
    List<Space> rows, {
    _i1.ColumnSelections<SpaceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Space>(
      rows,
      columns: columns?.call(Space.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Space]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Space> updateRow(
    _i1.DatabaseSession session,
    Space row, {
    _i1.ColumnSelections<SpaceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Space>(
      row,
      columns: columns?.call(Space.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Space] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Space?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<SpaceUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Space>(
      id,
      columnValues: columnValues(Space.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Space]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Space>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SpaceUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<SpaceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SpaceTable>? orderBy,
    _i1.OrderByListBuilder<SpaceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Space>(
      columnValues: columnValues(Space.t.updateTable),
      where: where(Space.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Space.t),
      orderByList: orderByList?.call(Space.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Space]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Space>> delete(
    _i1.DatabaseSession session,
    List<Space> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Space>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Space].
  Future<Space> deleteRow(
    _i1.DatabaseSession session,
    Space row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Space>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Space>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SpaceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Space>(
      where: where(Space.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SpaceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Space>(
      where: where?.call(Space.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Space] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SpaceTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Space>(
      where: where(Space.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
