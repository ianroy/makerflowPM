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

/// Agenda line item. Supports parent/child nesting and can link to a task or
/// project (the meeting → execution bridge) or be converted into one.
abstract class MeetingItem
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MeetingItem._({
    this.id,
    required this.organizationId,
    required this.agendaId,
    this.parentItemId,
    required this.title,
    this.notes,
    String? status,
    this.linkedTaskId,
    this.linkedProjectId,
    double? sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : status = status ?? 'open',
       sortOrder = sortOrder ?? 0.0;

  factory MeetingItem({
    int? id,
    required int organizationId,
    required int agendaId,
    int? parentItemId,
    required String title,
    String? notes,
    String? status,
    int? linkedTaskId,
    int? linkedProjectId,
    double? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _MeetingItemImpl;

  factory MeetingItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return MeetingItem(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      agendaId: jsonSerialization['agendaId'] as int,
      parentItemId: jsonSerialization['parentItemId'] as int?,
      title: jsonSerialization['title'] as String,
      notes: jsonSerialization['notes'] as String?,
      status: jsonSerialization['status'] as String?,
      linkedTaskId: jsonSerialization['linkedTaskId'] as int?,
      linkedProjectId: jsonSerialization['linkedProjectId'] as int?,
      sortOrder: (jsonSerialization['sortOrder'] as num?)?.toDouble(),
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

  static final t = MeetingItemTable();

  static const db = MeetingItemRepository._();

  @override
  int? id;

  int organizationId;

  int agendaId;

  int? parentItemId;

  String title;

  String? notes;

  String status;

  int? linkedTaskId;

  int? linkedProjectId;

  double sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MeetingItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MeetingItem copyWith({
    int? id,
    int? organizationId,
    int? agendaId,
    int? parentItemId,
    String? title,
    String? notes,
    String? status,
    int? linkedTaskId,
    int? linkedProjectId,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MeetingItem',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'agendaId': agendaId,
      if (parentItemId != null) 'parentItemId': parentItemId,
      'title': title,
      if (notes != null) 'notes': notes,
      'status': status,
      if (linkedTaskId != null) 'linkedTaskId': linkedTaskId,
      if (linkedProjectId != null) 'linkedProjectId': linkedProjectId,
      'sortOrder': sortOrder,
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
      '__className__': 'MeetingItem',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'agendaId': agendaId,
      if (parentItemId != null) 'parentItemId': parentItemId,
      'title': title,
      if (notes != null) 'notes': notes,
      'status': status,
      if (linkedTaskId != null) 'linkedTaskId': linkedTaskId,
      if (linkedProjectId != null) 'linkedProjectId': linkedProjectId,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static MeetingItemInclude include() {
    return MeetingItemInclude._();
  }

  static MeetingItemIncludeList includeList({
    _i1.WhereExpressionBuilder<MeetingItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingItemTable>? orderByList,
    MeetingItemInclude? include,
  }) {
    return MeetingItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MeetingItem.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MeetingItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MeetingItemImpl extends MeetingItem {
  _MeetingItemImpl({
    int? id,
    required int organizationId,
    required int agendaId,
    int? parentItemId,
    required String title,
    String? notes,
    String? status,
    int? linkedTaskId,
    int? linkedProjectId,
    double? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         agendaId: agendaId,
         parentItemId: parentItemId,
         title: title,
         notes: notes,
         status: status,
         linkedTaskId: linkedTaskId,
         linkedProjectId: linkedProjectId,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [MeetingItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MeetingItem copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? agendaId,
    Object? parentItemId = _Undefined,
    String? title,
    Object? notes = _Undefined,
    String? status,
    Object? linkedTaskId = _Undefined,
    Object? linkedProjectId = _Undefined,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return MeetingItem(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      agendaId: agendaId ?? this.agendaId,
      parentItemId: parentItemId is int? ? parentItemId : this.parentItemId,
      title: title ?? this.title,
      notes: notes is String? ? notes : this.notes,
      status: status ?? this.status,
      linkedTaskId: linkedTaskId is int? ? linkedTaskId : this.linkedTaskId,
      linkedProjectId: linkedProjectId is int?
          ? linkedProjectId
          : this.linkedProjectId,
      sortOrder: sortOrder ?? this.sortOrder,
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

class MeetingItemUpdateTable extends _i1.UpdateTable<MeetingItemTable> {
  MeetingItemUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<int, int> agendaId(int value) => _i1.ColumnValue(
    table.agendaId,
    value,
  );

  _i1.ColumnValue<int, int> parentItemId(int? value) => _i1.ColumnValue(
    table.parentItemId,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> notes(String? value) => _i1.ColumnValue(
    table.notes,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<int, int> linkedTaskId(int? value) => _i1.ColumnValue(
    table.linkedTaskId,
    value,
  );

  _i1.ColumnValue<int, int> linkedProjectId(int? value) => _i1.ColumnValue(
    table.linkedProjectId,
    value,
  );

  _i1.ColumnValue<double, double> sortOrder(double value) => _i1.ColumnValue(
    table.sortOrder,
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

class MeetingItemTable extends _i1.Table<int?> {
  MeetingItemTable({super.tableRelation}) : super(tableName: 'meeting_item') {
    updateTable = MeetingItemUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    agendaId = _i1.ColumnInt(
      'agendaId',
      this,
    );
    parentItemId = _i1.ColumnInt(
      'parentItemId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    notes = _i1.ColumnString(
      'notes',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    linkedTaskId = _i1.ColumnInt(
      'linkedTaskId',
      this,
    );
    linkedProjectId = _i1.ColumnInt(
      'linkedProjectId',
      this,
    );
    sortOrder = _i1.ColumnDouble(
      'sortOrder',
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

  late final MeetingItemUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnInt agendaId;

  late final _i1.ColumnInt parentItemId;

  late final _i1.ColumnString title;

  late final _i1.ColumnString notes;

  late final _i1.ColumnString status;

  late final _i1.ColumnInt linkedTaskId;

  late final _i1.ColumnInt linkedProjectId;

  late final _i1.ColumnDouble sortOrder;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnInt createdByUserInfoId;

  late final _i1.ColumnDateTime deletedAt;

  late final _i1.ColumnInt deletedByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    agendaId,
    parentItemId,
    title,
    notes,
    status,
    linkedTaskId,
    linkedProjectId,
    sortOrder,
    createdAt,
    updatedAt,
    createdByUserInfoId,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class MeetingItemInclude extends _i1.IncludeObject {
  MeetingItemInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MeetingItem.t;
}

class MeetingItemIncludeList extends _i1.IncludeList {
  MeetingItemIncludeList._({
    _i1.WhereExpressionBuilder<MeetingItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MeetingItem.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MeetingItem.t;
}

class MeetingItemRepository {
  const MeetingItemRepository._();

  /// Returns a list of [MeetingItem]s matching the given query parameters.
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
  Future<List<MeetingItem>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingItemTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingItemTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MeetingItem>(
      where: where?.call(MeetingItem.t),
      orderBy: orderBy?.call(MeetingItem.t),
      orderByList: orderByList?.call(MeetingItem.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MeetingItem] matching the given query parameters.
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
  Future<MeetingItem?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingItemTable>? where,
    int? offset,
    _i1.OrderByBuilder<MeetingItemTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MeetingItemTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MeetingItem>(
      where: where?.call(MeetingItem.t),
      orderBy: orderBy?.call(MeetingItem.t),
      orderByList: orderByList?.call(MeetingItem.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MeetingItem] by its [id] or null if no such row exists.
  Future<MeetingItem?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MeetingItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MeetingItem]s in the list and returns the inserted rows.
  ///
  /// The returned [MeetingItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MeetingItem>> insert(
    _i1.DatabaseSession session,
    List<MeetingItem> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MeetingItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MeetingItem] and returns the inserted row.
  ///
  /// The returned [MeetingItem] will have its `id` field set.
  Future<MeetingItem> insertRow(
    _i1.DatabaseSession session,
    MeetingItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MeetingItem>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MeetingItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MeetingItem>> update(
    _i1.DatabaseSession session,
    List<MeetingItem> rows, {
    _i1.ColumnSelections<MeetingItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MeetingItem>(
      rows,
      columns: columns?.call(MeetingItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MeetingItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MeetingItem> updateRow(
    _i1.DatabaseSession session,
    MeetingItem row, {
    _i1.ColumnSelections<MeetingItemTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MeetingItem>(
      row,
      columns: columns?.call(MeetingItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MeetingItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MeetingItem?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MeetingItemUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MeetingItem>(
      id,
      columnValues: columnValues(MeetingItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MeetingItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MeetingItem>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MeetingItemUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MeetingItemTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MeetingItemTable>? orderBy,
    _i1.OrderByListBuilder<MeetingItemTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MeetingItem>(
      columnValues: columnValues(MeetingItem.t.updateTable),
      where: where(MeetingItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MeetingItem.t),
      orderByList: orderByList?.call(MeetingItem.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MeetingItem]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MeetingItem>> delete(
    _i1.DatabaseSession session,
    List<MeetingItem> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MeetingItem>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MeetingItem].
  Future<MeetingItem> deleteRow(
    _i1.DatabaseSession session,
    MeetingItem row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MeetingItem>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MeetingItem>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MeetingItemTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MeetingItem>(
      where: where(MeetingItem.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MeetingItemTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MeetingItem>(
      where: where?.call(MeetingItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MeetingItem] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MeetingItemTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MeetingItem>(
      where: where(MeetingItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
