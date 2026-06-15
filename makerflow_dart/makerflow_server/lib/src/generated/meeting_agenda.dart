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

/// Tactical meeting agenda. Items hang off it (meeting_item).
abstract class MeetingAgenda
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MeetingAgenda._({
    this.id,
    required this.organizationId,
    required this.title,
    this.meetingAt,
    String? status,
    this.ownerUserInfoId,
    this.teamId,
    this.spaceId,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : status = status ?? 'draft';

  factory MeetingAgenda({
    int? id,
    required int organizationId,
    required String title,
    DateTime? meetingAt,
    String? status,
    int? ownerUserInfoId,
    int? teamId,
    int? spaceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _MeetingAgendaImpl;

  factory MeetingAgenda.fromJson(Map<String, dynamic> jsonSerialization) {
    return MeetingAgenda(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      title: jsonSerialization['title'] as String,
      meetingAt: jsonSerialization['meetingAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['meetingAt']),
      status: jsonSerialization['status'] as String?,
      ownerUserInfoId: jsonSerialization['ownerUserInfoId'] as int?,
      teamId: jsonSerialization['teamId'] as int?,
      spaceId: jsonSerialization['spaceId'] as int?,
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

  static final t = MeetingAgendaTable();

  static const db = MeetingAgendaRepository._();

  @override
  int? id;

  int organizationId;

  String title;

  DateTime? meetingAt;

  String status;

  int? ownerUserInfoId;

  int? teamId;

  int? spaceId;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MeetingAgenda]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MeetingAgenda copyWith({
    int? id,
    int? organizationId,
    String? title,
    DateTime? meetingAt,
    String? status,
    int? ownerUserInfoId,
    int? teamId,
    int? spaceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MeetingAgenda',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'title': title,
      if (meetingAt != null) 'meetingAt': meetingAt?.toJson(),
      'status': status,
      if (ownerUserInfoId != null) 'ownerUserInfoId': ownerUserInfoId,
      if (teamId != null) 'teamId': teamId,
      if (spaceId != null) 'spaceId': spaceId,
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
      '__className__': 'MeetingAgenda',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'title': title,
      if (meetingAt != null) 'meetingAt': meetingAt?.toJson(),
      'status': status,
      if (ownerUserInfoId != null) 'ownerUserInfoId': ownerUserInfoId,
      if (teamId != null) 'teamId': teamId,
      if (spaceId != null) 'spaceId': spaceId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static MeetingAgendaInclude include() {
    return MeetingAgendaInclude._();
  }

  static MeetingAgendaIncludeList includeList({
    _i1.WhereExpressionBuilder<MeetingAgendaTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingAgendaTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingAgendaTable>? orderByList,
    MeetingAgendaInclude? include,
  }) {
    return MeetingAgendaIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MeetingAgenda.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MeetingAgenda.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MeetingAgendaImpl extends MeetingAgenda {
  _MeetingAgendaImpl({
    int? id,
    required int organizationId,
    required String title,
    DateTime? meetingAt,
    String? status,
    int? ownerUserInfoId,
    int? teamId,
    int? spaceId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         title: title,
         meetingAt: meetingAt,
         status: status,
         ownerUserInfoId: ownerUserInfoId,
         teamId: teamId,
         spaceId: spaceId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [MeetingAgenda]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MeetingAgenda copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? title,
    Object? meetingAt = _Undefined,
    String? status,
    Object? ownerUserInfoId = _Undefined,
    Object? teamId = _Undefined,
    Object? spaceId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return MeetingAgenda(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      title: title ?? this.title,
      meetingAt: meetingAt is DateTime? ? meetingAt : this.meetingAt,
      status: status ?? this.status,
      ownerUserInfoId: ownerUserInfoId is int?
          ? ownerUserInfoId
          : this.ownerUserInfoId,
      teamId: teamId is int? ? teamId : this.teamId,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
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

class MeetingAgendaUpdateTable extends _i1.UpdateTable<MeetingAgendaTable> {
  MeetingAgendaUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> meetingAt(DateTime? value) =>
      _i1.ColumnValue(
        table.meetingAt,
        value,
      );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<int, int> ownerUserInfoId(int? value) => _i1.ColumnValue(
    table.ownerUserInfoId,
    value,
  );

  _i1.ColumnValue<int, int> teamId(int? value) => _i1.ColumnValue(
    table.teamId,
    value,
  );

  _i1.ColumnValue<int, int> spaceId(int? value) => _i1.ColumnValue(
    table.spaceId,
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

class MeetingAgendaTable extends _i1.Table<int?> {
  MeetingAgendaTable({super.tableRelation})
    : super(tableName: 'meeting_agenda') {
    updateTable = MeetingAgendaUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    meetingAt = _i1.ColumnDateTime(
      'meetingAt',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    ownerUserInfoId = _i1.ColumnInt(
      'ownerUserInfoId',
      this,
    );
    teamId = _i1.ColumnInt(
      'teamId',
      this,
    );
    spaceId = _i1.ColumnInt(
      'spaceId',
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

  late final MeetingAgendaUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString title;

  late final _i1.ColumnDateTime meetingAt;

  late final _i1.ColumnString status;

  late final _i1.ColumnInt ownerUserInfoId;

  late final _i1.ColumnInt teamId;

  late final _i1.ColumnInt spaceId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnInt createdByUserInfoId;

  late final _i1.ColumnDateTime deletedAt;

  late final _i1.ColumnInt deletedByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    title,
    meetingAt,
    status,
    ownerUserInfoId,
    teamId,
    spaceId,
    createdAt,
    updatedAt,
    createdByUserInfoId,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class MeetingAgendaInclude extends _i1.IncludeObject {
  MeetingAgendaInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MeetingAgenda.t;
}

class MeetingAgendaIncludeList extends _i1.IncludeList {
  MeetingAgendaIncludeList._({
    _i1.WhereExpressionBuilder<MeetingAgendaTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MeetingAgenda.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MeetingAgenda.t;
}

class MeetingAgendaRepository {
  const MeetingAgendaRepository._();

  /// Returns a list of [MeetingAgenda]s matching the given query parameters.
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
  Future<List<MeetingAgenda>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingAgendaTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingAgendaTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingAgendaTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MeetingAgenda>(
      where: where?.call(MeetingAgenda.t),
      orderBy: orderBy?.call(MeetingAgenda.t),
      orderByList: orderByList?.call(MeetingAgenda.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MeetingAgenda] matching the given query parameters.
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
  Future<MeetingAgenda?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingAgendaTable>? where,
    int? offset,
    _i1.OrderByBuilder<MeetingAgendaTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingAgendaTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MeetingAgenda>(
      where: where?.call(MeetingAgenda.t),
      orderBy: orderBy?.call(MeetingAgenda.t),
      orderByList: orderByList?.call(MeetingAgenda.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MeetingAgenda] by its [id] or null if no such row exists.
  Future<MeetingAgenda?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MeetingAgenda>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MeetingAgenda]s in the list and returns the inserted rows.
  ///
  /// The returned [MeetingAgenda]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MeetingAgenda>> insert(
    _i1.DatabaseSession session,
    List<MeetingAgenda> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MeetingAgenda>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MeetingAgenda] and returns the inserted row.
  ///
  /// The returned [MeetingAgenda] will have its `id` field set.
  Future<MeetingAgenda> insertRow(
    _i1.DatabaseSession session,
    MeetingAgenda row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MeetingAgenda>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MeetingAgenda]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MeetingAgenda>> update(
    _i1.DatabaseSession session,
    List<MeetingAgenda> rows, {
    _i1.ColumnSelections<MeetingAgendaTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MeetingAgenda>(
      rows,
      columns: columns?.call(MeetingAgenda.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MeetingAgenda]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MeetingAgenda> updateRow(
    _i1.DatabaseSession session,
    MeetingAgenda row, {
    _i1.ColumnSelections<MeetingAgendaTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MeetingAgenda>(
      row,
      columns: columns?.call(MeetingAgenda.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MeetingAgenda] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MeetingAgenda?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MeetingAgendaUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MeetingAgenda>(
      id,
      columnValues: columnValues(MeetingAgenda.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MeetingAgenda]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MeetingAgenda>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MeetingAgendaUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MeetingAgendaTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingAgendaTable>? orderBy,
    _i1.OrderByListBuilder<MeetingAgendaTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MeetingAgenda>(
      columnValues: columnValues(MeetingAgenda.t.updateTable),
      where: where(MeetingAgenda.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MeetingAgenda.t),
      orderByList: orderByList?.call(MeetingAgenda.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MeetingAgenda]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MeetingAgenda>> delete(
    _i1.DatabaseSession session,
    List<MeetingAgenda> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MeetingAgenda>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MeetingAgenda].
  Future<MeetingAgenda> deleteRow(
    _i1.DatabaseSession session,
    MeetingAgenda row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MeetingAgenda>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MeetingAgenda>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MeetingAgendaTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MeetingAgenda>(
      where: where(MeetingAgenda.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingAgendaTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MeetingAgenda>(
      where: where?.call(MeetingAgenda.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MeetingAgenda] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MeetingAgendaTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MeetingAgenda>(
      where: where(MeetingAgenda.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
