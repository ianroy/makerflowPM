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

/// Timeline entry (note/comment) on a meeting item.
/// NB: named *Note*, not *Update* — Serverpod generates a `MeetingItemUpdateTable`
/// helper for the `MeetingItem` model, which would collide with a model named
/// `MeetingItemUpdate`.
abstract class MeetingItemNote
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MeetingItemNote._({
    this.id,
    required this.organizationId,
    required this.itemId,
    required this.body,
    required this.createdAt,
    this.createdByUserInfoId,
  });

  factory MeetingItemNote({
    int? id,
    required int organizationId,
    required int itemId,
    required String body,
    required DateTime createdAt,
    int? createdByUserInfoId,
  }) = _MeetingItemNoteImpl;

  factory MeetingItemNote.fromJson(Map<String, dynamic> jsonSerialization) {
    return MeetingItemNote(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      itemId: jsonSerialization['itemId'] as int,
      body: jsonSerialization['body'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      createdByUserInfoId: jsonSerialization['createdByUserInfoId'] as int?,
    );
  }

  static final t = MeetingItemNoteTable();

  static const db = MeetingItemNoteRepository._();

  @override
  int? id;

  int organizationId;

  int itemId;

  String body;

  DateTime createdAt;

  int? createdByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MeetingItemNote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MeetingItemNote copyWith({
    int? id,
    int? organizationId,
    int? itemId,
    String? body,
    DateTime? createdAt,
    int? createdByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MeetingItemNote',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'itemId': itemId,
      'body': body,
      'createdAt': createdAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MeetingItemNote',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'itemId': itemId,
      'body': body,
      'createdAt': createdAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
    };
  }

  static MeetingItemNoteInclude include() {
    return MeetingItemNoteInclude._();
  }

  static MeetingItemNoteIncludeList includeList({
    _i1.WhereExpressionBuilder<MeetingItemNoteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingItemNoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingItemNoteTable>? orderByList,
    MeetingItemNoteInclude? include,
  }) {
    return MeetingItemNoteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MeetingItemNote.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MeetingItemNote.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MeetingItemNoteImpl extends MeetingItemNote {
  _MeetingItemNoteImpl({
    int? id,
    required int organizationId,
    required int itemId,
    required String body,
    required DateTime createdAt,
    int? createdByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         itemId: itemId,
         body: body,
         createdAt: createdAt,
         createdByUserInfoId: createdByUserInfoId,
       );

  /// Returns a shallow copy of this [MeetingItemNote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MeetingItemNote copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? itemId,
    String? body,
    DateTime? createdAt,
    Object? createdByUserInfoId = _Undefined,
  }) {
    return MeetingItemNote(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      itemId: itemId ?? this.itemId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      createdByUserInfoId: createdByUserInfoId is int?
          ? createdByUserInfoId
          : this.createdByUserInfoId,
    );
  }
}

class MeetingItemNoteUpdateTable extends _i1.UpdateTable<MeetingItemNoteTable> {
  MeetingItemNoteUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<int, int> itemId(int value) => _i1.ColumnValue(
    table.itemId,
    value,
  );

  _i1.ColumnValue<String, String> body(String value) => _i1.ColumnValue(
    table.body,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<int, int> createdByUserInfoId(int? value) => _i1.ColumnValue(
    table.createdByUserInfoId,
    value,
  );
}

class MeetingItemNoteTable extends _i1.Table<int?> {
  MeetingItemNoteTable({super.tableRelation})
    : super(tableName: 'meeting_item_note') {
    updateTable = MeetingItemNoteUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    itemId = _i1.ColumnInt(
      'itemId',
      this,
    );
    body = _i1.ColumnString(
      'body',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    createdByUserInfoId = _i1.ColumnInt(
      'createdByUserInfoId',
      this,
    );
  }

  late final MeetingItemNoteUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnInt itemId;

  late final _i1.ColumnString body;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnInt createdByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    itemId,
    body,
    createdAt,
    createdByUserInfoId,
  ];
}

class MeetingItemNoteInclude extends _i1.IncludeObject {
  MeetingItemNoteInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MeetingItemNote.t;
}

class MeetingItemNoteIncludeList extends _i1.IncludeList {
  MeetingItemNoteIncludeList._({
    _i1.WhereExpressionBuilder<MeetingItemNoteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MeetingItemNote.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MeetingItemNote.t;
}

class MeetingItemNoteRepository {
  const MeetingItemNoteRepository._();

  /// Returns a list of [MeetingItemNote]s matching the given query parameters.
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
  Future<List<MeetingItemNote>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingItemNoteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingItemNoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingItemNoteTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MeetingItemNote>(
      where: where?.call(MeetingItemNote.t),
      orderBy: orderBy?.call(MeetingItemNote.t),
      orderByList: orderByList?.call(MeetingItemNote.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MeetingItemNote] matching the given query parameters.
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
  Future<MeetingItemNote?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingItemNoteTable>? where,
    int? offset,
    _i1.OrderByBuilder<MeetingItemNoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingItemNoteTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MeetingItemNote>(
      where: where?.call(MeetingItemNote.t),
      orderBy: orderBy?.call(MeetingItemNote.t),
      orderByList: orderByList?.call(MeetingItemNote.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MeetingItemNote] by its [id] or null if no such row exists.
  Future<MeetingItemNote?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MeetingItemNote>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MeetingItemNote]s in the list and returns the inserted rows.
  ///
  /// The returned [MeetingItemNote]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MeetingItemNote>> insert(
    _i1.DatabaseSession session,
    List<MeetingItemNote> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MeetingItemNote>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MeetingItemNote] and returns the inserted row.
  ///
  /// The returned [MeetingItemNote] will have its `id` field set.
  Future<MeetingItemNote> insertRow(
    _i1.DatabaseSession session,
    MeetingItemNote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MeetingItemNote>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MeetingItemNote]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MeetingItemNote>> update(
    _i1.DatabaseSession session,
    List<MeetingItemNote> rows, {
    _i1.ColumnSelections<MeetingItemNoteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MeetingItemNote>(
      rows,
      columns: columns?.call(MeetingItemNote.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MeetingItemNote]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MeetingItemNote> updateRow(
    _i1.DatabaseSession session,
    MeetingItemNote row, {
    _i1.ColumnSelections<MeetingItemNoteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MeetingItemNote>(
      row,
      columns: columns?.call(MeetingItemNote.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MeetingItemNote] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MeetingItemNote?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MeetingItemNoteUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MeetingItemNote>(
      id,
      columnValues: columnValues(MeetingItemNote.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MeetingItemNote]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MeetingItemNote>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MeetingItemNoteUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MeetingItemNoteTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingItemNoteTable>? orderBy,
    _i1.OrderByListBuilder<MeetingItemNoteTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MeetingItemNote>(
      columnValues: columnValues(MeetingItemNote.t.updateTable),
      where: where(MeetingItemNote.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MeetingItemNote.t),
      orderByList: orderByList?.call(MeetingItemNote.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MeetingItemNote]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MeetingItemNote>> delete(
    _i1.DatabaseSession session,
    List<MeetingItemNote> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MeetingItemNote>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MeetingItemNote].
  Future<MeetingItemNote> deleteRow(
    _i1.DatabaseSession session,
    MeetingItemNote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MeetingItemNote>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MeetingItemNote>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MeetingItemNoteTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MeetingItemNote>(
      where: where(MeetingItemNote.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingItemNoteTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MeetingItemNote>(
      where: where?.call(MeetingItemNote.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MeetingItemNote] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MeetingItemNoteTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MeetingItemNote>(
      where: where(MeetingItemNote.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
