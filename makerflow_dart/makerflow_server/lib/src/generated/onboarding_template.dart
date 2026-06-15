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

/// Role-based onboarding checklist. itemsJson holds the ordered steps.
abstract class OnboardingTemplate
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  OnboardingTemplate._({
    this.id,
    required this.organizationId,
    required this.name,
    this.forRole,
    required this.itemsJson,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserInfoId,
  });

  factory OnboardingTemplate({
    int? id,
    required int organizationId,
    required String name,
    _i2.MembershipRole? forRole,
    required String itemsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _OnboardingTemplateImpl;

  factory OnboardingTemplate.fromJson(Map<String, dynamic> jsonSerialization) {
    return OnboardingTemplate(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      forRole: jsonSerialization['forRole'] == null
          ? null
          : _i2.MembershipRole.fromJson(
              (jsonSerialization['forRole'] as String),
            ),
      itemsJson: jsonSerialization['itemsJson'] as String,
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

  static final t = OnboardingTemplateTable();

  static const db = OnboardingTemplateRepository._();

  @override
  int? id;

  int organizationId;

  String name;

  _i2.MembershipRole? forRole;

  String itemsJson;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [OnboardingTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OnboardingTemplate copyWith({
    int? id,
    int? organizationId,
    String? name,
    _i2.MembershipRole? forRole,
    String? itemsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OnboardingTemplate',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (forRole != null) 'forRole': forRole?.toJson(),
      'itemsJson': itemsJson,
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
      '__className__': 'OnboardingTemplate',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (forRole != null) 'forRole': forRole?.toJson(),
      'itemsJson': itemsJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static OnboardingTemplateInclude include() {
    return OnboardingTemplateInclude._();
  }

  static OnboardingTemplateIncludeList includeList({
    _i1.WhereExpressionBuilder<OnboardingTemplateTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OnboardingTemplateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OnboardingTemplateTable>? orderByList,
    OnboardingTemplateInclude? include,
  }) {
    return OnboardingTemplateIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OnboardingTemplate.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(OnboardingTemplate.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OnboardingTemplateImpl extends OnboardingTemplate {
  _OnboardingTemplateImpl({
    int? id,
    required int organizationId,
    required String name,
    _i2.MembershipRole? forRole,
    required String itemsJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         forRole: forRole,
         itemsJson: itemsJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [OnboardingTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OnboardingTemplate copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    Object? forRole = _Undefined,
    String? itemsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return OnboardingTemplate(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      forRole: forRole is _i2.MembershipRole? ? forRole : this.forRole,
      itemsJson: itemsJson ?? this.itemsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByUserInfoId: deletedByUserInfoId is int?
          ? deletedByUserInfoId
          : this.deletedByUserInfoId,
    );
  }
}

class OnboardingTemplateUpdateTable
    extends _i1.UpdateTable<OnboardingTemplateTable> {
  OnboardingTemplateUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<_i2.MembershipRole, _i2.MembershipRole> forRole(
    _i2.MembershipRole? value,
  ) => _i1.ColumnValue(
    table.forRole,
    value,
  );

  _i1.ColumnValue<String, String> itemsJson(String value) => _i1.ColumnValue(
    table.itemsJson,
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

class OnboardingTemplateTable extends _i1.Table<int?> {
  OnboardingTemplateTable({super.tableRelation})
    : super(tableName: 'onboarding_template') {
    updateTable = OnboardingTemplateUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    forRole = _i1.ColumnEnum(
      'forRole',
      this,
      _i1.EnumSerialization.byName,
    );
    itemsJson = _i1.ColumnString(
      'itemsJson',
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

  late final OnboardingTemplateUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString name;

  late final _i1.ColumnEnum<_i2.MembershipRole> forRole;

  late final _i1.ColumnString itemsJson;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime deletedAt;

  late final _i1.ColumnInt deletedByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    name,
    forRole,
    itemsJson,
    createdAt,
    updatedAt,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class OnboardingTemplateInclude extends _i1.IncludeObject {
  OnboardingTemplateInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => OnboardingTemplate.t;
}

class OnboardingTemplateIncludeList extends _i1.IncludeList {
  OnboardingTemplateIncludeList._({
    _i1.WhereExpressionBuilder<OnboardingTemplateTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OnboardingTemplate.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => OnboardingTemplate.t;
}

class OnboardingTemplateRepository {
  const OnboardingTemplateRepository._();

  /// Returns a list of [OnboardingTemplate]s matching the given query parameters.
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
  Future<List<OnboardingTemplate>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OnboardingTemplateTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OnboardingTemplateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OnboardingTemplateTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OnboardingTemplate>(
      where: where?.call(OnboardingTemplate.t),
      orderBy: orderBy?.call(OnboardingTemplate.t),
      orderByList: orderByList?.call(OnboardingTemplate.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OnboardingTemplate] matching the given query parameters.
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
  Future<OnboardingTemplate?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OnboardingTemplateTable>? where,
    int? offset,
    _i1.OrderByBuilder<OnboardingTemplateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OnboardingTemplateTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OnboardingTemplate>(
      where: where?.call(OnboardingTemplate.t),
      orderBy: orderBy?.call(OnboardingTemplate.t),
      orderByList: orderByList?.call(OnboardingTemplate.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OnboardingTemplate] by its [id] or null if no such row exists.
  Future<OnboardingTemplate?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OnboardingTemplate>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OnboardingTemplate]s in the list and returns the inserted rows.
  ///
  /// The returned [OnboardingTemplate]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<OnboardingTemplate>> insert(
    _i1.DatabaseSession session,
    List<OnboardingTemplate> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<OnboardingTemplate>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [OnboardingTemplate] and returns the inserted row.
  ///
  /// The returned [OnboardingTemplate] will have its `id` field set.
  Future<OnboardingTemplate> insertRow(
    _i1.DatabaseSession session,
    OnboardingTemplate row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<OnboardingTemplate>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [OnboardingTemplate]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<OnboardingTemplate>> update(
    _i1.DatabaseSession session,
    List<OnboardingTemplate> rows, {
    _i1.ColumnSelections<OnboardingTemplateTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<OnboardingTemplate>(
      rows,
      columns: columns?.call(OnboardingTemplate.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OnboardingTemplate]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OnboardingTemplate> updateRow(
    _i1.DatabaseSession session,
    OnboardingTemplate row, {
    _i1.ColumnSelections<OnboardingTemplateTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<OnboardingTemplate>(
      row,
      columns: columns?.call(OnboardingTemplate.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OnboardingTemplate] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OnboardingTemplate?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<OnboardingTemplateUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<OnboardingTemplate>(
      id,
      columnValues: columnValues(OnboardingTemplate.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OnboardingTemplate]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<OnboardingTemplate>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<OnboardingTemplateUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<OnboardingTemplateTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OnboardingTemplateTable>? orderBy,
    _i1.OrderByListBuilder<OnboardingTemplateTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<OnboardingTemplate>(
      columnValues: columnValues(OnboardingTemplate.t.updateTable),
      where: where(OnboardingTemplate.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OnboardingTemplate.t),
      orderByList: orderByList?.call(OnboardingTemplate.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [OnboardingTemplate]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<OnboardingTemplate>> delete(
    _i1.DatabaseSession session,
    List<OnboardingTemplate> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<OnboardingTemplate>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [OnboardingTemplate].
  Future<OnboardingTemplate> deleteRow(
    _i1.DatabaseSession session,
    OnboardingTemplate row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OnboardingTemplate>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<OnboardingTemplate>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OnboardingTemplateTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<OnboardingTemplate>(
      where: where(OnboardingTemplate.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OnboardingTemplateTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<OnboardingTemplate>(
      where: where?.call(OnboardingTemplate.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OnboardingTemplate] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OnboardingTemplateTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OnboardingTemplate>(
      where: where(OnboardingTemplate.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
