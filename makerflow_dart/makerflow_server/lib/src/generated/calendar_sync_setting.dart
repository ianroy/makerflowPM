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

/// Per-user Google Calendar OAuth + sync config. Secrets are encrypted at
/// rest (see Appendix G); never log token fields.
abstract class CalendarSyncSetting
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CalendarSyncSetting._({
    this.id,
    required this.organizationId,
    required this.userInfoId,
    String? calendarId,
    this.refreshTokenEnc,
    bool? enabled,
    this.lastSyncedAt,
    required this.updatedAt,
  }) : calendarId = calendarId ?? 'primary',
       enabled = enabled ?? false;

  factory CalendarSyncSetting({
    int? id,
    required int organizationId,
    required int userInfoId,
    String? calendarId,
    String? refreshTokenEnc,
    bool? enabled,
    DateTime? lastSyncedAt,
    required DateTime updatedAt,
  }) = _CalendarSyncSettingImpl;

  factory CalendarSyncSetting.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarSyncSetting(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      userInfoId: jsonSerialization['userInfoId'] as int,
      calendarId: jsonSerialization['calendarId'] as String?,
      refreshTokenEnc: jsonSerialization['refreshTokenEnc'] as String?,
      enabled: jsonSerialization['enabled'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarSyncSettingTable();

  static const db = CalendarSyncSettingRepository._();

  @override
  int? id;

  int organizationId;

  int userInfoId;

  String calendarId;

  String? refreshTokenEnc;

  bool enabled;

  DateTime? lastSyncedAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarSyncSetting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CalendarSyncSetting copyWith({
    int? id,
    int? organizationId,
    int? userInfoId,
    String? calendarId,
    String? refreshTokenEnc,
    bool? enabled,
    DateTime? lastSyncedAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CalendarSyncSetting',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'userInfoId': userInfoId,
      'calendarId': calendarId,
      if (refreshTokenEnc != null) 'refreshTokenEnc': refreshTokenEnc,
      'enabled': enabled,
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CalendarSyncSetting',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'userInfoId': userInfoId,
      'calendarId': calendarId,
      if (refreshTokenEnc != null) 'refreshTokenEnc': refreshTokenEnc,
      'enabled': enabled,
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static CalendarSyncSettingInclude include() {
    return CalendarSyncSettingInclude._();
  }

  static CalendarSyncSettingIncludeList includeList({
    _i1.WhereExpressionBuilder<CalendarSyncSettingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CalendarSyncSettingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CalendarSyncSettingTable>? orderByList,
    CalendarSyncSettingInclude? include,
  }) {
    return CalendarSyncSettingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSyncSetting.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CalendarSyncSetting.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSyncSettingImpl extends CalendarSyncSetting {
  _CalendarSyncSettingImpl({
    int? id,
    required int organizationId,
    required int userInfoId,
    String? calendarId,
    String? refreshTokenEnc,
    bool? enabled,
    DateTime? lastSyncedAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         userInfoId: userInfoId,
         calendarId: calendarId,
         refreshTokenEnc: refreshTokenEnc,
         enabled: enabled,
         lastSyncedAt: lastSyncedAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarSyncSetting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CalendarSyncSetting copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? userInfoId,
    String? calendarId,
    Object? refreshTokenEnc = _Undefined,
    bool? enabled,
    Object? lastSyncedAt = _Undefined,
    DateTime? updatedAt,
  }) {
    return CalendarSyncSetting(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      userInfoId: userInfoId ?? this.userInfoId,
      calendarId: calendarId ?? this.calendarId,
      refreshTokenEnc: refreshTokenEnc is String?
          ? refreshTokenEnc
          : this.refreshTokenEnc,
      enabled: enabled ?? this.enabled,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarSyncSettingUpdateTable
    extends _i1.UpdateTable<CalendarSyncSettingTable> {
  CalendarSyncSettingUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<int, int> userInfoId(int value) => _i1.ColumnValue(
    table.userInfoId,
    value,
  );

  _i1.ColumnValue<String, String> calendarId(String value) => _i1.ColumnValue(
    table.calendarId,
    value,
  );

  _i1.ColumnValue<String, String> refreshTokenEnc(String? value) =>
      _i1.ColumnValue(
        table.refreshTokenEnc,
        value,
      );

  _i1.ColumnValue<bool, bool> enabled(bool value) => _i1.ColumnValue(
    table.enabled,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastSyncedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastSyncedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class CalendarSyncSettingTable extends _i1.Table<int?> {
  CalendarSyncSettingTable({super.tableRelation})
    : super(tableName: 'calendar_sync_setting') {
    updateTable = CalendarSyncSettingUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    userInfoId = _i1.ColumnInt(
      'userInfoId',
      this,
    );
    calendarId = _i1.ColumnString(
      'calendarId',
      this,
      hasDefault: true,
    );
    refreshTokenEnc = _i1.ColumnString(
      'refreshTokenEnc',
      this,
    );
    enabled = _i1.ColumnBool(
      'enabled',
      this,
      hasDefault: true,
    );
    lastSyncedAt = _i1.ColumnDateTime(
      'lastSyncedAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final CalendarSyncSettingUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnInt userInfoId;

  late final _i1.ColumnString calendarId;

  late final _i1.ColumnString refreshTokenEnc;

  late final _i1.ColumnBool enabled;

  late final _i1.ColumnDateTime lastSyncedAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    userInfoId,
    calendarId,
    refreshTokenEnc,
    enabled,
    lastSyncedAt,
    updatedAt,
  ];
}

class CalendarSyncSettingInclude extends _i1.IncludeObject {
  CalendarSyncSettingInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CalendarSyncSetting.t;
}

class CalendarSyncSettingIncludeList extends _i1.IncludeList {
  CalendarSyncSettingIncludeList._({
    _i1.WhereExpressionBuilder<CalendarSyncSettingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSyncSetting.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CalendarSyncSetting.t;
}

class CalendarSyncSettingRepository {
  const CalendarSyncSettingRepository._();

  /// Returns a list of [CalendarSyncSetting]s matching the given query parameters.
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
  Future<List<CalendarSyncSetting>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CalendarSyncSettingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CalendarSyncSettingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CalendarSyncSettingTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSyncSetting>(
      where: where?.call(CalendarSyncSetting.t),
      orderBy: orderBy?.call(CalendarSyncSetting.t),
      orderByList: orderByList?.call(CalendarSyncSetting.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSyncSetting] matching the given query parameters.
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
  Future<CalendarSyncSetting?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CalendarSyncSettingTable>? where,
    int? offset,
    _i1.OrderByBuilder<CalendarSyncSettingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CalendarSyncSettingTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSyncSetting>(
      where: where?.call(CalendarSyncSetting.t),
      orderBy: orderBy?.call(CalendarSyncSetting.t),
      orderByList: orderByList?.call(CalendarSyncSetting.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSyncSetting] by its [id] or null if no such row exists.
  Future<CalendarSyncSetting?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSyncSetting>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSyncSetting]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSyncSetting]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CalendarSyncSetting>> insert(
    _i1.DatabaseSession session,
    List<CalendarSyncSetting> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CalendarSyncSetting>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CalendarSyncSetting] and returns the inserted row.
  ///
  /// The returned [CalendarSyncSetting] will have its `id` field set.
  Future<CalendarSyncSetting> insertRow(
    _i1.DatabaseSession session,
    CalendarSyncSetting row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSyncSetting>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSyncSetting]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CalendarSyncSetting>> update(
    _i1.DatabaseSession session,
    List<CalendarSyncSetting> rows, {
    _i1.ColumnSelections<CalendarSyncSettingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CalendarSyncSetting>(
      rows,
      columns: columns?.call(CalendarSyncSetting.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSyncSetting]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSyncSetting> updateRow(
    _i1.DatabaseSession session,
    CalendarSyncSetting row, {
    _i1.ColumnSelections<CalendarSyncSettingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSyncSetting>(
      row,
      columns: columns?.call(CalendarSyncSetting.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSyncSetting] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSyncSetting?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CalendarSyncSettingUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSyncSetting>(
      id,
      columnValues: columnValues(CalendarSyncSetting.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSyncSetting]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CalendarSyncSetting>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CalendarSyncSettingUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<CalendarSyncSettingTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CalendarSyncSettingTable>? orderBy,
    _i1.OrderByListBuilder<CalendarSyncSettingTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CalendarSyncSetting>(
      columnValues: columnValues(CalendarSyncSetting.t.updateTable),
      where: where(CalendarSyncSetting.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSyncSetting.t),
      orderByList: orderByList?.call(CalendarSyncSetting.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CalendarSyncSetting]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CalendarSyncSetting>> delete(
    _i1.DatabaseSession session,
    List<CalendarSyncSetting> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CalendarSyncSetting>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CalendarSyncSetting].
  Future<CalendarSyncSetting> deleteRow(
    _i1.DatabaseSession session,
    CalendarSyncSetting row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSyncSetting>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CalendarSyncSetting>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CalendarSyncSettingTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CalendarSyncSetting>(
      where: where(CalendarSyncSetting.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CalendarSyncSettingTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSyncSetting>(
      where: where?.call(CalendarSyncSetting.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSyncSetting] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CalendarSyncSettingTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSyncSetting>(
      where: where(CalendarSyncSetting.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
