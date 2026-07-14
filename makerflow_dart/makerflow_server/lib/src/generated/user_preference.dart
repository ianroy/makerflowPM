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

/// Per-user UI/workflow settings (theme, timezone, locale, notifications,
/// session-timeout accommodation). Pinned in the local cache for offline.
abstract class UserPreference
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  UserPreference._({
    this.id,
    required this.userInfoId,
    String? theme,
    String? locale,
    this.timezone,
    this.notificationsJson,
    this.sessionTimeoutSeconds,
    this.uiJson,
    required this.updatedAt,
  }) : theme = theme ?? 'dark',
       locale = locale ?? 'en';

  factory UserPreference({
    int? id,
    required int userInfoId,
    String? theme,
    String? locale,
    String? timezone,
    String? notificationsJson,
    int? sessionTimeoutSeconds,
    String? uiJson,
    required DateTime updatedAt,
  }) = _UserPreferenceImpl;

  factory UserPreference.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserPreference(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int,
      theme: jsonSerialization['theme'] as String?,
      locale: jsonSerialization['locale'] as String?,
      timezone: jsonSerialization['timezone'] as String?,
      notificationsJson: jsonSerialization['notificationsJson'] as String?,
      sessionTimeoutSeconds: jsonSerialization['sessionTimeoutSeconds'] as int?,
      uiJson: jsonSerialization['uiJson'] as String?,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = UserPreferenceTable();

  static const db = UserPreferenceRepository._();

  @override
  int? id;

  int userInfoId;

  String theme;

  String locale;

  String? timezone;

  String? notificationsJson;

  int? sessionTimeoutSeconds;

  String? uiJson;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [UserPreference]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  UserPreference copyWith({
    int? id,
    int? userInfoId,
    String? theme,
    String? locale,
    String? timezone,
    String? notificationsJson,
    int? sessionTimeoutSeconds,
    String? uiJson,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserPreference',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      'theme': theme,
      'locale': locale,
      if (timezone != null) 'timezone': timezone,
      if (notificationsJson != null) 'notificationsJson': notificationsJson,
      if (sessionTimeoutSeconds != null)
        'sessionTimeoutSeconds': sessionTimeoutSeconds,
      if (uiJson != null) 'uiJson': uiJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserPreference',
      if (id != null) 'id': id,
      'userInfoId': userInfoId,
      'theme': theme,
      'locale': locale,
      if (timezone != null) 'timezone': timezone,
      if (notificationsJson != null) 'notificationsJson': notificationsJson,
      if (sessionTimeoutSeconds != null)
        'sessionTimeoutSeconds': sessionTimeoutSeconds,
      if (uiJson != null) 'uiJson': uiJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static UserPreferenceInclude include() {
    return UserPreferenceInclude._();
  }

  static UserPreferenceIncludeList includeList({
    _i1.WhereExpressionBuilder<UserPreferenceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserPreferenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserPreferenceTable>? orderByList,
    UserPreferenceInclude? include,
  }) {
    return UserPreferenceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserPreference.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(UserPreference.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserPreferenceImpl extends UserPreference {
  _UserPreferenceImpl({
    int? id,
    required int userInfoId,
    String? theme,
    String? locale,
    String? timezone,
    String? notificationsJson,
    int? sessionTimeoutSeconds,
    String? uiJson,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         userInfoId: userInfoId,
         theme: theme,
         locale: locale,
         timezone: timezone,
         notificationsJson: notificationsJson,
         sessionTimeoutSeconds: sessionTimeoutSeconds,
         uiJson: uiJson,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [UserPreference]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  UserPreference copyWith({
    Object? id = _Undefined,
    int? userInfoId,
    String? theme,
    String? locale,
    Object? timezone = _Undefined,
    Object? notificationsJson = _Undefined,
    Object? sessionTimeoutSeconds = _Undefined,
    Object? uiJson = _Undefined,
    DateTime? updatedAt,
  }) {
    return UserPreference(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId ?? this.userInfoId,
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
      timezone: timezone is String? ? timezone : this.timezone,
      notificationsJson: notificationsJson is String?
          ? notificationsJson
          : this.notificationsJson,
      sessionTimeoutSeconds: sessionTimeoutSeconds is int?
          ? sessionTimeoutSeconds
          : this.sessionTimeoutSeconds,
      uiJson: uiJson is String? ? uiJson : this.uiJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserPreferenceUpdateTable extends _i1.UpdateTable<UserPreferenceTable> {
  UserPreferenceUpdateTable(super.table);

  _i1.ColumnValue<int, int> userInfoId(int value) => _i1.ColumnValue(
    table.userInfoId,
    value,
  );

  _i1.ColumnValue<String, String> theme(String value) => _i1.ColumnValue(
    table.theme,
    value,
  );

  _i1.ColumnValue<String, String> locale(String value) => _i1.ColumnValue(
    table.locale,
    value,
  );

  _i1.ColumnValue<String, String> timezone(String? value) => _i1.ColumnValue(
    table.timezone,
    value,
  );

  _i1.ColumnValue<String, String> notificationsJson(String? value) =>
      _i1.ColumnValue(
        table.notificationsJson,
        value,
      );

  _i1.ColumnValue<int, int> sessionTimeoutSeconds(int? value) =>
      _i1.ColumnValue(
        table.sessionTimeoutSeconds,
        value,
      );

  _i1.ColumnValue<String, String> uiJson(String? value) => _i1.ColumnValue(
    table.uiJson,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class UserPreferenceTable extends _i1.Table<int?> {
  UserPreferenceTable({super.tableRelation})
    : super(tableName: 'user_preference') {
    updateTable = UserPreferenceUpdateTable(this);
    userInfoId = _i1.ColumnInt(
      'userInfoId',
      this,
    );
    theme = _i1.ColumnString(
      'theme',
      this,
      hasDefault: true,
    );
    locale = _i1.ColumnString(
      'locale',
      this,
      hasDefault: true,
    );
    timezone = _i1.ColumnString(
      'timezone',
      this,
    );
    notificationsJson = _i1.ColumnString(
      'notificationsJson',
      this,
    );
    sessionTimeoutSeconds = _i1.ColumnInt(
      'sessionTimeoutSeconds',
      this,
    );
    uiJson = _i1.ColumnString(
      'uiJson',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final UserPreferenceUpdateTable updateTable;

  late final _i1.ColumnInt userInfoId;

  late final _i1.ColumnString theme;

  late final _i1.ColumnString locale;

  late final _i1.ColumnString timezone;

  late final _i1.ColumnString notificationsJson;

  late final _i1.ColumnInt sessionTimeoutSeconds;

  late final _i1.ColumnString uiJson;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    userInfoId,
    theme,
    locale,
    timezone,
    notificationsJson,
    sessionTimeoutSeconds,
    uiJson,
    updatedAt,
  ];
}

class UserPreferenceInclude extends _i1.IncludeObject {
  UserPreferenceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => UserPreference.t;
}

class UserPreferenceIncludeList extends _i1.IncludeList {
  UserPreferenceIncludeList._({
    _i1.WhereExpressionBuilder<UserPreferenceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(UserPreference.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => UserPreference.t;
}

class UserPreferenceRepository {
  const UserPreferenceRepository._();

  /// Returns a list of [UserPreference]s matching the given query parameters.
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
  Future<List<UserPreference>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserPreferenceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserPreferenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserPreferenceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<UserPreference>(
      where: where?.call(UserPreference.t),
      orderBy: orderBy?.call(UserPreference.t),
      orderByList: orderByList?.call(UserPreference.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [UserPreference] matching the given query parameters.
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
  Future<UserPreference?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserPreferenceTable>? where,
    int? offset,
    _i1.OrderByBuilder<UserPreferenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<UserPreferenceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<UserPreference>(
      where: where?.call(UserPreference.t),
      orderBy: orderBy?.call(UserPreference.t),
      orderByList: orderByList?.call(UserPreference.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [UserPreference] by its [id] or null if no such row exists.
  Future<UserPreference?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<UserPreference>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [UserPreference]s in the list and returns the inserted rows.
  ///
  /// The returned [UserPreference]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<UserPreference>> insert(
    _i1.DatabaseSession session,
    List<UserPreference> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<UserPreference>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [UserPreference] and returns the inserted row.
  ///
  /// The returned [UserPreference] will have its `id` field set.
  Future<UserPreference> insertRow(
    _i1.DatabaseSession session,
    UserPreference row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<UserPreference>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [UserPreference]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<UserPreference>> update(
    _i1.DatabaseSession session,
    List<UserPreference> rows, {
    _i1.ColumnSelections<UserPreferenceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<UserPreference>(
      rows,
      columns: columns?.call(UserPreference.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserPreference]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<UserPreference> updateRow(
    _i1.DatabaseSession session,
    UserPreference row, {
    _i1.ColumnSelections<UserPreferenceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<UserPreference>(
      row,
      columns: columns?.call(UserPreference.t),
      transaction: transaction,
    );
  }

  /// Updates a single [UserPreference] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<UserPreference?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<UserPreferenceUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<UserPreference>(
      id,
      columnValues: columnValues(UserPreference.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [UserPreference]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<UserPreference>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<UserPreferenceUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<UserPreferenceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<UserPreferenceTable>? orderBy,
    _i1.OrderByListBuilder<UserPreferenceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<UserPreference>(
      columnValues: columnValues(UserPreference.t.updateTable),
      where: where(UserPreference.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(UserPreference.t),
      orderByList: orderByList?.call(UserPreference.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [UserPreference]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<UserPreference>> delete(
    _i1.DatabaseSession session,
    List<UserPreference> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<UserPreference>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [UserPreference].
  Future<UserPreference> deleteRow(
    _i1.DatabaseSession session,
    UserPreference row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<UserPreference>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<UserPreference>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserPreferenceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<UserPreference>(
      where: where(UserPreference.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<UserPreferenceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<UserPreference>(
      where: where?.call(UserPreference.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [UserPreference] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<UserPreferenceTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<UserPreference>(
      where: where(UserPreference.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
