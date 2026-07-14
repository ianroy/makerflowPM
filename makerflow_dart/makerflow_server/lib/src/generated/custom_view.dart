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

/// Saved filter/column set (per user, optionally shared). filtersJson and
/// columnsJson hold serialized config (the legacy custom_views payload).
abstract class CustomView
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CustomView._({
    this.id,
    required this.organizationId,
    required this.ownerUserInfoId,
    required this.name,
    required this.entityType,
    required this.filtersJson,
    required this.columnsJson,
    bool? isShared,
    int? version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : isShared = isShared ?? false,
       version = version ?? 1;

  factory CustomView({
    int? id,
    required int organizationId,
    required int ownerUserInfoId,
    required String name,
    required String entityType,
    required String filtersJson,
    required String columnsJson,
    bool? isShared,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
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
      version: jsonSerialization['version'] as int?,
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

  static final t = CustomViewTable();

  static const db = CustomViewRepository._();

  @override
  int? id;

  int organizationId;

  int ownerUserInfoId;

  String name;

  String entityType;

  String filtersJson;

  String columnsJson;

  bool isShared;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

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
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
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
      'version': version,
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
      '__className__': 'CustomView',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'ownerUserInfoId': ownerUserInfoId,
      'name': name,
      'entityType': entityType,
      'filtersJson': filtersJson,
      'columnsJson': columnsJson,
      'isShared': isShared,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static CustomViewInclude include() {
    return CustomViewInclude._();
  }

  static CustomViewIncludeList includeList({
    _i1.WhereExpressionBuilder<CustomViewTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CustomViewTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CustomViewTable>? orderByList,
    CustomViewInclude? include,
  }) {
    return CustomViewIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomView.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CustomView.t),
      include: include,
    );
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
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         ownerUserInfoId: ownerUserInfoId,
         name: name,
         entityType: entityType,
         filtersJson: filtersJson,
         columnsJson: columnsJson,
         isShared: isShared,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
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
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
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
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByUserInfoId: deletedByUserInfoId is int?
          ? deletedByUserInfoId
          : this.deletedByUserInfoId,
    );
  }
}

class CustomViewUpdateTable extends _i1.UpdateTable<CustomViewTable> {
  CustomViewUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<int, int> ownerUserInfoId(int value) => _i1.ColumnValue(
    table.ownerUserInfoId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> entityType(String value) => _i1.ColumnValue(
    table.entityType,
    value,
  );

  _i1.ColumnValue<String, String> filtersJson(String value) => _i1.ColumnValue(
    table.filtersJson,
    value,
  );

  _i1.ColumnValue<String, String> columnsJson(String value) => _i1.ColumnValue(
    table.columnsJson,
    value,
  );

  _i1.ColumnValue<bool, bool> isShared(bool value) => _i1.ColumnValue(
    table.isShared,
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

class CustomViewTable extends _i1.Table<int?> {
  CustomViewTable({super.tableRelation}) : super(tableName: 'custom_view') {
    updateTable = CustomViewUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    ownerUserInfoId = _i1.ColumnInt(
      'ownerUserInfoId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    entityType = _i1.ColumnString(
      'entityType',
      this,
    );
    filtersJson = _i1.ColumnString(
      'filtersJson',
      this,
    );
    columnsJson = _i1.ColumnString(
      'columnsJson',
      this,
    );
    isShared = _i1.ColumnBool(
      'isShared',
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
    deletedAt = _i1.ColumnDateTime(
      'deletedAt',
      this,
    );
    deletedByUserInfoId = _i1.ColumnInt(
      'deletedByUserInfoId',
      this,
    );
  }

  late final CustomViewUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnInt ownerUserInfoId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString entityType;

  late final _i1.ColumnString filtersJson;

  late final _i1.ColumnString columnsJson;

  late final _i1.ColumnBool isShared;

  late final _i1.ColumnInt version;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime deletedAt;

  late final _i1.ColumnInt deletedByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    ownerUserInfoId,
    name,
    entityType,
    filtersJson,
    columnsJson,
    isShared,
    version,
    createdAt,
    updatedAt,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class CustomViewInclude extends _i1.IncludeObject {
  CustomViewInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CustomView.t;
}

class CustomViewIncludeList extends _i1.IncludeList {
  CustomViewIncludeList._({
    _i1.WhereExpressionBuilder<CustomViewTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CustomView.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CustomView.t;
}

class CustomViewRepository {
  const CustomViewRepository._();

  /// Returns a list of [CustomView]s matching the given query parameters.
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
  Future<List<CustomView>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CustomViewTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CustomViewTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CustomViewTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CustomView>(
      where: where?.call(CustomView.t),
      orderBy: orderBy?.call(CustomView.t),
      orderByList: orderByList?.call(CustomView.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CustomView] matching the given query parameters.
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
  Future<CustomView?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CustomViewTable>? where,
    int? offset,
    _i1.OrderByBuilder<CustomViewTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CustomViewTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CustomView>(
      where: where?.call(CustomView.t),
      orderBy: orderBy?.call(CustomView.t),
      orderByList: orderByList?.call(CustomView.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CustomView] by its [id] or null if no such row exists.
  Future<CustomView?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CustomView>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CustomView]s in the list and returns the inserted rows.
  ///
  /// The returned [CustomView]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CustomView>> insert(
    _i1.DatabaseSession session,
    List<CustomView> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CustomView>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CustomView] and returns the inserted row.
  ///
  /// The returned [CustomView] will have its `id` field set.
  Future<CustomView> insertRow(
    _i1.DatabaseSession session,
    CustomView row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CustomView>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CustomView]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CustomView>> update(
    _i1.DatabaseSession session,
    List<CustomView> rows, {
    _i1.ColumnSelections<CustomViewTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CustomView>(
      rows,
      columns: columns?.call(CustomView.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustomView]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CustomView> updateRow(
    _i1.DatabaseSession session,
    CustomView row, {
    _i1.ColumnSelections<CustomViewTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CustomView>(
      row,
      columns: columns?.call(CustomView.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustomView] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CustomView?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CustomViewUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CustomView>(
      id,
      columnValues: columnValues(CustomView.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CustomView]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CustomView>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CustomViewUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CustomViewTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CustomViewTable>? orderBy,
    _i1.OrderByListBuilder<CustomViewTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CustomView>(
      columnValues: columnValues(CustomView.t.updateTable),
      where: where(CustomView.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomView.t),
      orderByList: orderByList?.call(CustomView.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CustomView]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CustomView>> delete(
    _i1.DatabaseSession session,
    List<CustomView> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CustomView>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CustomView].
  Future<CustomView> deleteRow(
    _i1.DatabaseSession session,
    CustomView row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CustomView>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CustomView>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CustomViewTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CustomView>(
      where: where(CustomView.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CustomViewTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CustomView>(
      where: where?.call(CustomView.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CustomView] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CustomViewTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CustomView>(
      where: where(CustomView.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
