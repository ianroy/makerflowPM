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

/// Saved report configuration (per org, visibility-scoped).
abstract class ReportTemplate
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  ReportTemplate._({
    this.id,
    required this.organizationId,
    required this.name,
    required this.configJson,
    String? visibility,
    this.ownerUserInfoId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : visibility = visibility ?? 'org';

  factory ReportTemplate({
    int? id,
    required int organizationId,
    required String name,
    required String configJson,
    String? visibility,
    int? ownerUserInfoId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _ReportTemplateImpl;

  factory ReportTemplate.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReportTemplate(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      configJson: jsonSerialization['configJson'] as String,
      visibility: jsonSerialization['visibility'] as String?,
      ownerUserInfoId: jsonSerialization['ownerUserInfoId'] as int?,
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

  static final t = ReportTemplateTable();

  static const db = ReportTemplateRepository._();

  @override
  int? id;

  int organizationId;

  String name;

  String configJson;

  String visibility;

  int? ownerUserInfoId;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ReportTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ReportTemplate copyWith({
    int? id,
    int? organizationId,
    String? name,
    String? configJson,
    String? visibility,
    int? ownerUserInfoId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReportTemplate',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      'configJson': configJson,
      'visibility': visibility,
      if (ownerUserInfoId != null) 'ownerUserInfoId': ownerUserInfoId,
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
      '__className__': 'ReportTemplate',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      'configJson': configJson,
      'visibility': visibility,
      if (ownerUserInfoId != null) 'ownerUserInfoId': ownerUserInfoId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static ReportTemplateInclude include() {
    return ReportTemplateInclude._();
  }

  static ReportTemplateIncludeList includeList({
    _i1.WhereExpressionBuilder<ReportTemplateTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ReportTemplateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ReportTemplateTable>? orderByList,
    ReportTemplateInclude? include,
  }) {
    return ReportTemplateIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReportTemplate.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ReportTemplate.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReportTemplateImpl extends ReportTemplate {
  _ReportTemplateImpl({
    int? id,
    required int organizationId,
    required String name,
    required String configJson,
    String? visibility,
    int? ownerUserInfoId,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         configJson: configJson,
         visibility: visibility,
         ownerUserInfoId: ownerUserInfoId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [ReportTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ReportTemplate copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    String? configJson,
    String? visibility,
    Object? ownerUserInfoId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return ReportTemplate(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      configJson: configJson ?? this.configJson,
      visibility: visibility ?? this.visibility,
      ownerUserInfoId: ownerUserInfoId is int?
          ? ownerUserInfoId
          : this.ownerUserInfoId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      deletedByUserInfoId: deletedByUserInfoId is int?
          ? deletedByUserInfoId
          : this.deletedByUserInfoId,
    );
  }
}

class ReportTemplateUpdateTable extends _i1.UpdateTable<ReportTemplateTable> {
  ReportTemplateUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> configJson(String value) => _i1.ColumnValue(
    table.configJson,
    value,
  );

  _i1.ColumnValue<String, String> visibility(String value) => _i1.ColumnValue(
    table.visibility,
    value,
  );

  _i1.ColumnValue<int, int> ownerUserInfoId(int? value) => _i1.ColumnValue(
    table.ownerUserInfoId,
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

class ReportTemplateTable extends _i1.Table<int?> {
  ReportTemplateTable({super.tableRelation})
    : super(tableName: 'report_template') {
    updateTable = ReportTemplateUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    configJson = _i1.ColumnString(
      'configJson',
      this,
    );
    visibility = _i1.ColumnString(
      'visibility',
      this,
      hasDefault: true,
    );
    ownerUserInfoId = _i1.ColumnInt(
      'ownerUserInfoId',
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

  late final ReportTemplateUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString configJson;

  late final _i1.ColumnString visibility;

  late final _i1.ColumnInt ownerUserInfoId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime deletedAt;

  late final _i1.ColumnInt deletedByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    name,
    configJson,
    visibility,
    ownerUserInfoId,
    createdAt,
    updatedAt,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class ReportTemplateInclude extends _i1.IncludeObject {
  ReportTemplateInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => ReportTemplate.t;
}

class ReportTemplateIncludeList extends _i1.IncludeList {
  ReportTemplateIncludeList._({
    _i1.WhereExpressionBuilder<ReportTemplateTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ReportTemplate.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ReportTemplate.t;
}

class ReportTemplateRepository {
  const ReportTemplateRepository._();

  /// Returns a list of [ReportTemplate]s matching the given query parameters.
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
  Future<List<ReportTemplate>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ReportTemplateTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ReportTemplateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ReportTemplateTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ReportTemplate>(
      where: where?.call(ReportTemplate.t),
      orderBy: orderBy?.call(ReportTemplate.t),
      orderByList: orderByList?.call(ReportTemplate.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ReportTemplate] matching the given query parameters.
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
  Future<ReportTemplate?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ReportTemplateTable>? where,
    int? offset,
    _i1.OrderByBuilder<ReportTemplateTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ReportTemplateTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ReportTemplate>(
      where: where?.call(ReportTemplate.t),
      orderBy: orderBy?.call(ReportTemplate.t),
      orderByList: orderByList?.call(ReportTemplate.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ReportTemplate] by its [id] or null if no such row exists.
  Future<ReportTemplate?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ReportTemplate>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ReportTemplate]s in the list and returns the inserted rows.
  ///
  /// The returned [ReportTemplate]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ReportTemplate>> insert(
    _i1.DatabaseSession session,
    List<ReportTemplate> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ReportTemplate>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ReportTemplate] and returns the inserted row.
  ///
  /// The returned [ReportTemplate] will have its `id` field set.
  Future<ReportTemplate> insertRow(
    _i1.DatabaseSession session,
    ReportTemplate row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ReportTemplate>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ReportTemplate]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ReportTemplate>> update(
    _i1.DatabaseSession session,
    List<ReportTemplate> rows, {
    _i1.ColumnSelections<ReportTemplateTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ReportTemplate>(
      rows,
      columns: columns?.call(ReportTemplate.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ReportTemplate]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ReportTemplate> updateRow(
    _i1.DatabaseSession session,
    ReportTemplate row, {
    _i1.ColumnSelections<ReportTemplateTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ReportTemplate>(
      row,
      columns: columns?.call(ReportTemplate.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ReportTemplate] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ReportTemplate?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ReportTemplateUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ReportTemplate>(
      id,
      columnValues: columnValues(ReportTemplate.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ReportTemplate]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ReportTemplate>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ReportTemplateUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ReportTemplateTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ReportTemplateTable>? orderBy,
    _i1.OrderByListBuilder<ReportTemplateTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ReportTemplate>(
      columnValues: columnValues(ReportTemplate.t.updateTable),
      where: where(ReportTemplate.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ReportTemplate.t),
      orderByList: orderByList?.call(ReportTemplate.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ReportTemplate]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ReportTemplate>> delete(
    _i1.DatabaseSession session,
    List<ReportTemplate> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ReportTemplate>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ReportTemplate].
  Future<ReportTemplate> deleteRow(
    _i1.DatabaseSession session,
    ReportTemplate row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ReportTemplate>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ReportTemplate>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ReportTemplateTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ReportTemplate>(
      where: where(ReportTemplate.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ReportTemplateTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ReportTemplate>(
      where: where?.call(ReportTemplate.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ReportTemplate] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ReportTemplateTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ReportTemplate>(
      where: where(ReportTemplate.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
