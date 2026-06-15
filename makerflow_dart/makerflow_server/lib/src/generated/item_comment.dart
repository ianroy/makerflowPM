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

/// Threaded comment on any entity (polymorphic via entityType+entityId).
/// Org-scoped, soft-deletable, audited, offline-cacheable.
abstract class ItemComment
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ItemComment._({
    this.id,
    required this.organizationId,
    required this.entityType,
    required this.entityId,
    this.parentCommentId,
    required this.body,
    this.clientUuid,
    int? version,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : version = version ?? 1;

  factory ItemComment({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    int? parentCommentId,
    required String body,
    String? clientUuid,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _ItemCommentImpl;

  factory ItemComment.fromJson(Map<String, dynamic> jsonSerialization) {
    return ItemComment(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as int,
      parentCommentId: jsonSerialization['parentCommentId'] as int?,
      body: jsonSerialization['body'] as String,
      clientUuid: jsonSerialization['clientUuid'] as String?,
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

  static final t = ItemCommentTable();

  static const db = ItemCommentRepository._();

  @override
  int? id;

  int organizationId;

  String entityType;

  int entityId;

  int? parentCommentId;

  String body;

  String? clientUuid;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ItemComment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ItemComment copyWith({
    int? id,
    int? organizationId,
    String? entityType,
    int? entityId,
    int? parentCommentId,
    String? body,
    String? clientUuid,
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
      '__className__': 'ItemComment',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'entityId': entityId,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      'body': body,
      if (clientUuid != null) 'clientUuid': clientUuid,
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
      '__className__': 'ItemComment',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'entityId': entityId,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      'body': body,
      if (clientUuid != null) 'clientUuid': clientUuid,
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

  static ItemCommentInclude include() {
    return ItemCommentInclude._();
  }

  static ItemCommentIncludeList includeList({
    _i1.WhereExpressionBuilder<ItemCommentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ItemCommentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ItemCommentTable>? orderByList,
    ItemCommentInclude? include,
  }) {
    return ItemCommentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ItemComment.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ItemComment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ItemCommentImpl extends ItemComment {
  _ItemCommentImpl({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    int? parentCommentId,
    required String body,
    String? clientUuid,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         entityType: entityType,
         entityId: entityId,
         parentCommentId: parentCommentId,
         body: body,
         clientUuid: clientUuid,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [ItemComment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ItemComment copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? entityType,
    int? entityId,
    Object? parentCommentId = _Undefined,
    String? body,
    Object? clientUuid = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return ItemComment(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      parentCommentId: parentCommentId is int?
          ? parentCommentId
          : this.parentCommentId,
      body: body ?? this.body,
      clientUuid: clientUuid is String? ? clientUuid : this.clientUuid,
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

class ItemCommentUpdateTable extends _i1.UpdateTable<ItemCommentTable> {
  ItemCommentUpdateTable(super.table);

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

  _i1.ColumnValue<int, int> parentCommentId(int? value) => _i1.ColumnValue(
    table.parentCommentId,
    value,
  );

  _i1.ColumnValue<String, String> body(String value) => _i1.ColumnValue(
    table.body,
    value,
  );

  _i1.ColumnValue<String, String> clientUuid(String? value) => _i1.ColumnValue(
    table.clientUuid,
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

class ItemCommentTable extends _i1.Table<int?> {
  ItemCommentTable({super.tableRelation}) : super(tableName: 'item_comment') {
    updateTable = ItemCommentUpdateTable(this);
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
    parentCommentId = _i1.ColumnInt(
      'parentCommentId',
      this,
    );
    body = _i1.ColumnString(
      'body',
      this,
    );
    clientUuid = _i1.ColumnString(
      'clientUuid',
      this,
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

  late final ItemCommentUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString entityType;

  late final _i1.ColumnInt entityId;

  late final _i1.ColumnInt parentCommentId;

  late final _i1.ColumnString body;

  late final _i1.ColumnString clientUuid;

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
    entityType,
    entityId,
    parentCommentId,
    body,
    clientUuid,
    version,
    createdAt,
    updatedAt,
    createdByUserInfoId,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class ItemCommentInclude extends _i1.IncludeObject {
  ItemCommentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ItemComment.t;
}

class ItemCommentIncludeList extends _i1.IncludeList {
  ItemCommentIncludeList._({
    _i1.WhereExpressionBuilder<ItemCommentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ItemComment.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ItemComment.t;
}

class ItemCommentRepository {
  const ItemCommentRepository._();

  /// Returns a list of [ItemComment]s matching the given query parameters.
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
  Future<List<ItemComment>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ItemCommentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ItemCommentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ItemCommentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ItemComment>(
      where: where?.call(ItemComment.t),
      orderBy: orderBy?.call(ItemComment.t),
      orderByList: orderByList?.call(ItemComment.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ItemComment] matching the given query parameters.
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
  Future<ItemComment?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ItemCommentTable>? where,
    int? offset,
    _i1.OrderByBuilder<ItemCommentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ItemCommentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ItemComment>(
      where: where?.call(ItemComment.t),
      orderBy: orderBy?.call(ItemComment.t),
      orderByList: orderByList?.call(ItemComment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ItemComment] by its [id] or null if no such row exists.
  Future<ItemComment?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ItemComment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ItemComment]s in the list and returns the inserted rows.
  ///
  /// The returned [ItemComment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ItemComment>> insert(
    _i1.DatabaseSession session,
    List<ItemComment> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ItemComment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ItemComment] and returns the inserted row.
  ///
  /// The returned [ItemComment] will have its `id` field set.
  Future<ItemComment> insertRow(
    _i1.DatabaseSession session,
    ItemComment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ItemComment>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ItemComment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ItemComment>> update(
    _i1.DatabaseSession session,
    List<ItemComment> rows, {
    _i1.ColumnSelections<ItemCommentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ItemComment>(
      rows,
      columns: columns?.call(ItemComment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ItemComment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ItemComment> updateRow(
    _i1.DatabaseSession session,
    ItemComment row, {
    _i1.ColumnSelections<ItemCommentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ItemComment>(
      row,
      columns: columns?.call(ItemComment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ItemComment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ItemComment?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ItemCommentUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ItemComment>(
      id,
      columnValues: columnValues(ItemComment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ItemComment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ItemComment>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ItemCommentUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ItemCommentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ItemCommentTable>? orderBy,
    _i1.OrderByListBuilder<ItemCommentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ItemComment>(
      columnValues: columnValues(ItemComment.t.updateTable),
      where: where(ItemComment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ItemComment.t),
      orderByList: orderByList?.call(ItemComment.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ItemComment]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ItemComment>> delete(
    _i1.DatabaseSession session,
    List<ItemComment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ItemComment>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ItemComment].
  Future<ItemComment> deleteRow(
    _i1.DatabaseSession session,
    ItemComment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ItemComment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ItemComment>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ItemCommentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ItemComment>(
      where: where(ItemComment.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ItemCommentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ItemComment>(
      where: where?.call(ItemComment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ItemComment] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ItemCommentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ItemComment>(
      where: where(ItemComment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
