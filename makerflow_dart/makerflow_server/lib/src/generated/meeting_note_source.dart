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

/// Calendar-driven metadata that seeds an agenda from an external event.
abstract class MeetingNoteSource
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MeetingNoteSource._({
    this.id,
    required this.organizationId,
    this.agendaId,
    this.calendarEventId,
    required this.sourceKind,
    this.rawJson,
    required this.createdAt,
  });

  factory MeetingNoteSource({
    int? id,
    required int organizationId,
    int? agendaId,
    int? calendarEventId,
    required String sourceKind,
    String? rawJson,
    required DateTime createdAt,
  }) = _MeetingNoteSourceImpl;

  factory MeetingNoteSource.fromJson(Map<String, dynamic> jsonSerialization) {
    return MeetingNoteSource(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      agendaId: jsonSerialization['agendaId'] as int?,
      calendarEventId: jsonSerialization['calendarEventId'] as int?,
      sourceKind: jsonSerialization['sourceKind'] as String,
      rawJson: jsonSerialization['rawJson'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = MeetingNoteSourceTable();

  static const db = MeetingNoteSourceRepository._();

  @override
  int? id;

  int organizationId;

  int? agendaId;

  int? calendarEventId;

  String sourceKind;

  String? rawJson;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MeetingNoteSource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MeetingNoteSource copyWith({
    int? id,
    int? organizationId,
    int? agendaId,
    int? calendarEventId,
    String? sourceKind,
    String? rawJson,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MeetingNoteSource',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      if (agendaId != null) 'agendaId': agendaId,
      if (calendarEventId != null) 'calendarEventId': calendarEventId,
      'sourceKind': sourceKind,
      if (rawJson != null) 'rawJson': rawJson,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MeetingNoteSource',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      if (agendaId != null) 'agendaId': agendaId,
      if (calendarEventId != null) 'calendarEventId': calendarEventId,
      'sourceKind': sourceKind,
      if (rawJson != null) 'rawJson': rawJson,
      'createdAt': createdAt.toJson(),
    };
  }

  static MeetingNoteSourceInclude include() {
    return MeetingNoteSourceInclude._();
  }

  static MeetingNoteSourceIncludeList includeList({
    _i1.WhereExpressionBuilder<MeetingNoteSourceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingNoteSourceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingNoteSourceTable>? orderByList,
    MeetingNoteSourceInclude? include,
  }) {
    return MeetingNoteSourceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MeetingNoteSource.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MeetingNoteSource.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MeetingNoteSourceImpl extends MeetingNoteSource {
  _MeetingNoteSourceImpl({
    int? id,
    required int organizationId,
    int? agendaId,
    int? calendarEventId,
    required String sourceKind,
    String? rawJson,
    required DateTime createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         agendaId: agendaId,
         calendarEventId: calendarEventId,
         sourceKind: sourceKind,
         rawJson: rawJson,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MeetingNoteSource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MeetingNoteSource copyWith({
    Object? id = _Undefined,
    int? organizationId,
    Object? agendaId = _Undefined,
    Object? calendarEventId = _Undefined,
    String? sourceKind,
    Object? rawJson = _Undefined,
    DateTime? createdAt,
  }) {
    return MeetingNoteSource(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      agendaId: agendaId is int? ? agendaId : this.agendaId,
      calendarEventId: calendarEventId is int?
          ? calendarEventId
          : this.calendarEventId,
      sourceKind: sourceKind ?? this.sourceKind,
      rawJson: rawJson is String? ? rawJson : this.rawJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MeetingNoteSourceUpdateTable
    extends _i1.UpdateTable<MeetingNoteSourceTable> {
  MeetingNoteSourceUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<int, int> agendaId(int? value) => _i1.ColumnValue(
    table.agendaId,
    value,
  );

  _i1.ColumnValue<int, int> calendarEventId(int? value) => _i1.ColumnValue(
    table.calendarEventId,
    value,
  );

  _i1.ColumnValue<String, String> sourceKind(String value) => _i1.ColumnValue(
    table.sourceKind,
    value,
  );

  _i1.ColumnValue<String, String> rawJson(String? value) => _i1.ColumnValue(
    table.rawJson,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class MeetingNoteSourceTable extends _i1.Table<int?> {
  MeetingNoteSourceTable({super.tableRelation})
    : super(tableName: 'meeting_note_source') {
    updateTable = MeetingNoteSourceUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    agendaId = _i1.ColumnInt(
      'agendaId',
      this,
    );
    calendarEventId = _i1.ColumnInt(
      'calendarEventId',
      this,
    );
    sourceKind = _i1.ColumnString(
      'sourceKind',
      this,
    );
    rawJson = _i1.ColumnString(
      'rawJson',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MeetingNoteSourceUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnInt agendaId;

  late final _i1.ColumnInt calendarEventId;

  late final _i1.ColumnString sourceKind;

  late final _i1.ColumnString rawJson;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    agendaId,
    calendarEventId,
    sourceKind,
    rawJson,
    createdAt,
  ];
}

class MeetingNoteSourceInclude extends _i1.IncludeObject {
  MeetingNoteSourceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MeetingNoteSource.t;
}

class MeetingNoteSourceIncludeList extends _i1.IncludeList {
  MeetingNoteSourceIncludeList._({
    _i1.WhereExpressionBuilder<MeetingNoteSourceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MeetingNoteSource.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MeetingNoteSource.t;
}

class MeetingNoteSourceRepository {
  const MeetingNoteSourceRepository._();

  /// Returns a list of [MeetingNoteSource]s matching the given query parameters.
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
  Future<List<MeetingNoteSource>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingNoteSourceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingNoteSourceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingNoteSourceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MeetingNoteSource>(
      where: where?.call(MeetingNoteSource.t),
      orderBy: orderBy?.call(MeetingNoteSource.t),
      orderByList: orderByList?.call(MeetingNoteSource.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MeetingNoteSource] matching the given query parameters.
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
  Future<MeetingNoteSource?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingNoteSourceTable>? where,
    int? offset,
    _i1.OrderByBuilder<MeetingNoteSourceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingNoteSourceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MeetingNoteSource>(
      where: where?.call(MeetingNoteSource.t),
      orderBy: orderBy?.call(MeetingNoteSource.t),
      orderByList: orderByList?.call(MeetingNoteSource.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MeetingNoteSource] by its [id] or null if no such row exists.
  Future<MeetingNoteSource?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MeetingNoteSource>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MeetingNoteSource]s in the list and returns the inserted rows.
  ///
  /// The returned [MeetingNoteSource]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MeetingNoteSource>> insert(
    _i1.DatabaseSession session,
    List<MeetingNoteSource> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MeetingNoteSource>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MeetingNoteSource] and returns the inserted row.
  ///
  /// The returned [MeetingNoteSource] will have its `id` field set.
  Future<MeetingNoteSource> insertRow(
    _i1.DatabaseSession session,
    MeetingNoteSource row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MeetingNoteSource>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MeetingNoteSource]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MeetingNoteSource>> update(
    _i1.DatabaseSession session,
    List<MeetingNoteSource> rows, {
    _i1.ColumnSelections<MeetingNoteSourceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MeetingNoteSource>(
      rows,
      columns: columns?.call(MeetingNoteSource.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MeetingNoteSource]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MeetingNoteSource> updateRow(
    _i1.DatabaseSession session,
    MeetingNoteSource row, {
    _i1.ColumnSelections<MeetingNoteSourceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MeetingNoteSource>(
      row,
      columns: columns?.call(MeetingNoteSource.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MeetingNoteSource] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MeetingNoteSource?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MeetingNoteSourceUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MeetingNoteSource>(
      id,
      columnValues: columnValues(MeetingNoteSource.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MeetingNoteSource]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MeetingNoteSource>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MeetingNoteSourceUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MeetingNoteSourceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingNoteSourceTable>? orderBy,
    _i1.OrderByListBuilder<MeetingNoteSourceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MeetingNoteSource>(
      columnValues: columnValues(MeetingNoteSource.t.updateTable),
      where: where(MeetingNoteSource.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MeetingNoteSource.t),
      orderByList: orderByList?.call(MeetingNoteSource.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MeetingNoteSource]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MeetingNoteSource>> delete(
    _i1.DatabaseSession session,
    List<MeetingNoteSource> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MeetingNoteSource>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MeetingNoteSource].
  Future<MeetingNoteSource> deleteRow(
    _i1.DatabaseSession session,
    MeetingNoteSource row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MeetingNoteSource>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MeetingNoteSource>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MeetingNoteSourceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MeetingNoteSource>(
      where: where(MeetingNoteSource.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingNoteSourceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MeetingNoteSource>(
      where: where?.call(MeetingNoteSource.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MeetingNoteSource] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MeetingNoteSourceTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MeetingNoteSource>(
      where: where(MeetingNoteSource.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
