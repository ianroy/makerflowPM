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
import 'enums/membership_role.dart' as _i2;

/// Per-role default sidebar/nav config for an org (legacy role_nav_preferences).
abstract class RoleNavPreference
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  RoleNavPreference._({
    this.id,
    required this.organizationId,
    required this.role,
    required this.navJson,
    required this.updatedAt,
  });

  factory RoleNavPreference({
    int? id,
    required int organizationId,
    required _i2.MembershipRole role,
    required String navJson,
    required DateTime updatedAt,
  }) = _RoleNavPreferenceImpl;

  factory RoleNavPreference.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoleNavPreference(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      role: _i2.MembershipRole.fromJson((jsonSerialization['role'] as String)),
      navJson: jsonSerialization['navJson'] as String,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = RoleNavPreferenceTable();

  static const db = RoleNavPreferenceRepository._();

  @override
  int? id;

  int organizationId;

  _i2.MembershipRole role;

  String navJson;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [RoleNavPreference]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RoleNavPreference copyWith({
    int? id,
    int? organizationId,
    _i2.MembershipRole? role,
    String? navJson,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoleNavPreference',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'role': role.toJson(),
      'navJson': navJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoleNavPreference',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'role': role.toJson(),
      'navJson': navJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static RoleNavPreferenceInclude include() {
    return RoleNavPreferenceInclude._();
  }

  static RoleNavPreferenceIncludeList includeList({
    _i1.WhereExpressionBuilder<RoleNavPreferenceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RoleNavPreferenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RoleNavPreferenceTable>? orderByList,
    RoleNavPreferenceInclude? include,
  }) {
    return RoleNavPreferenceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoleNavPreference.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RoleNavPreference.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoleNavPreferenceImpl extends RoleNavPreference {
  _RoleNavPreferenceImpl({
    int? id,
    required int organizationId,
    required _i2.MembershipRole role,
    required String navJson,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         role: role,
         navJson: navJson,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [RoleNavPreference]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RoleNavPreference copyWith({
    Object? id = _Undefined,
    int? organizationId,
    _i2.MembershipRole? role,
    String? navJson,
    DateTime? updatedAt,
  }) {
    return RoleNavPreference(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      role: role ?? this.role,
      navJson: navJson ?? this.navJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RoleNavPreferenceUpdateTable
    extends _i1.UpdateTable<RoleNavPreferenceTable> {
  RoleNavPreferenceUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<_i2.MembershipRole, _i2.MembershipRole> role(
    _i2.MembershipRole value,
  ) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<String, String> navJson(String value) => _i1.ColumnValue(
    table.navJson,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );
}

class RoleNavPreferenceTable extends _i1.Table<int?> {
  RoleNavPreferenceTable({super.tableRelation})
    : super(tableName: 'role_nav_preference') {
    updateTable = RoleNavPreferenceUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    navJson = _i1.ColumnString(
      'navJson',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final RoleNavPreferenceUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnEnum<_i2.MembershipRole> role;

  late final _i1.ColumnString navJson;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    role,
    navJson,
    updatedAt,
  ];
}

class RoleNavPreferenceInclude extends _i1.IncludeObject {
  RoleNavPreferenceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => RoleNavPreference.t;
}

class RoleNavPreferenceIncludeList extends _i1.IncludeList {
  RoleNavPreferenceIncludeList._({
    _i1.WhereExpressionBuilder<RoleNavPreferenceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RoleNavPreference.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => RoleNavPreference.t;
}

class RoleNavPreferenceRepository {
  const RoleNavPreferenceRepository._();

  /// Returns a list of [RoleNavPreference]s matching the given query parameters.
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
  Future<List<RoleNavPreference>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RoleNavPreferenceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RoleNavPreferenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RoleNavPreferenceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<RoleNavPreference>(
      where: where?.call(RoleNavPreference.t),
      orderBy: orderBy?.call(RoleNavPreference.t),
      orderByList: orderByList?.call(RoleNavPreference.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [RoleNavPreference] matching the given query parameters.
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
  Future<RoleNavPreference?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RoleNavPreferenceTable>? where,
    int? offset,
    _i1.OrderByBuilder<RoleNavPreferenceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RoleNavPreferenceTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<RoleNavPreference>(
      where: where?.call(RoleNavPreference.t),
      orderBy: orderBy?.call(RoleNavPreference.t),
      orderByList: orderByList?.call(RoleNavPreference.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [RoleNavPreference] by its [id] or null if no such row exists.
  Future<RoleNavPreference?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<RoleNavPreference>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [RoleNavPreference]s in the list and returns the inserted rows.
  ///
  /// The returned [RoleNavPreference]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<RoleNavPreference>> insert(
    _i1.DatabaseSession session,
    List<RoleNavPreference> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<RoleNavPreference>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [RoleNavPreference] and returns the inserted row.
  ///
  /// The returned [RoleNavPreference] will have its `id` field set.
  Future<RoleNavPreference> insertRow(
    _i1.DatabaseSession session,
    RoleNavPreference row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RoleNavPreference>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RoleNavPreference]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RoleNavPreference>> update(
    _i1.DatabaseSession session,
    List<RoleNavPreference> rows, {
    _i1.ColumnSelections<RoleNavPreferenceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RoleNavPreference>(
      rows,
      columns: columns?.call(RoleNavPreference.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RoleNavPreference]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RoleNavPreference> updateRow(
    _i1.DatabaseSession session,
    RoleNavPreference row, {
    _i1.ColumnSelections<RoleNavPreferenceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<RoleNavPreference>(
      row,
      columns: columns?.call(RoleNavPreference.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RoleNavPreference] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<RoleNavPreference?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<RoleNavPreferenceUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<RoleNavPreference>(
      id,
      columnValues: columnValues(RoleNavPreference.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [RoleNavPreference]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<RoleNavPreference>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<RoleNavPreferenceUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<RoleNavPreferenceTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RoleNavPreferenceTable>? orderBy,
    _i1.OrderByListBuilder<RoleNavPreferenceTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<RoleNavPreference>(
      columnValues: columnValues(RoleNavPreference.t.updateTable),
      where: where(RoleNavPreference.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RoleNavPreference.t),
      orderByList: orderByList?.call(RoleNavPreference.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [RoleNavPreference]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RoleNavPreference>> delete(
    _i1.DatabaseSession session,
    List<RoleNavPreference> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RoleNavPreference>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RoleNavPreference].
  Future<RoleNavPreference> deleteRow(
    _i1.DatabaseSession session,
    RoleNavPreference row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RoleNavPreference>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RoleNavPreference>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RoleNavPreferenceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RoleNavPreference>(
      where: where(RoleNavPreference.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<RoleNavPreferenceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RoleNavPreference>(
      where: where?.call(RoleNavPreference.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [RoleNavPreference] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<RoleNavPreferenceTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<RoleNavPreference>(
      where: where(RoleNavPreference.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
