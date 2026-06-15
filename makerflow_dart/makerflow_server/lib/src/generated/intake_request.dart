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
import 'enums/intake_stage.dart' as _i2;

/// Scored intake queue (feature-flagged; matches legacy FEATURE_INTAKE_ENABLED).
abstract class IntakeRequest
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  IntakeRequest._({
    this.id,
    required this.organizationId,
    required this.title,
    this.description,
    _i2.IntakeStage? stage,
    this.score,
    this.requesterName,
    this.requesterEmail,
    this.convertedProjectId,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : stage = stage ?? _i2.IntakeStage.submitted;

  factory IntakeRequest({
    int? id,
    required int organizationId,
    required String title,
    String? description,
    _i2.IntakeStage? stage,
    double? score,
    String? requesterName,
    String? requesterEmail,
    int? convertedProjectId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _IntakeRequestImpl;

  factory IntakeRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return IntakeRequest(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      stage: jsonSerialization['stage'] == null
          ? null
          : _i2.IntakeStage.fromJson((jsonSerialization['stage'] as String)),
      score: (jsonSerialization['score'] as num?)?.toDouble(),
      requesterName: jsonSerialization['requesterName'] as String?,
      requesterEmail: jsonSerialization['requesterEmail'] as String?,
      convertedProjectId: jsonSerialization['convertedProjectId'] as int?,
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

  static final t = IntakeRequestTable();

  static const db = IntakeRequestRepository._();

  @override
  int? id;

  int organizationId;

  String title;

  String? description;

  _i2.IntakeStage stage;

  double? score;

  String? requesterName;

  String? requesterEmail;

  int? convertedProjectId;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [IntakeRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IntakeRequest copyWith({
    int? id,
    int? organizationId,
    String? title,
    String? description,
    _i2.IntakeStage? stage,
    double? score,
    String? requesterName,
    String? requesterEmail,
    int? convertedProjectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IntakeRequest',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'title': title,
      if (description != null) 'description': description,
      'stage': stage.toJson(),
      if (score != null) 'score': score,
      if (requesterName != null) 'requesterName': requesterName,
      if (requesterEmail != null) 'requesterEmail': requesterEmail,
      if (convertedProjectId != null) 'convertedProjectId': convertedProjectId,
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
      '__className__': 'IntakeRequest',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'title': title,
      if (description != null) 'description': description,
      'stage': stage.toJson(),
      if (score != null) 'score': score,
      if (requesterName != null) 'requesterName': requesterName,
      if (requesterEmail != null) 'requesterEmail': requesterEmail,
      if (convertedProjectId != null) 'convertedProjectId': convertedProjectId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static IntakeRequestInclude include() {
    return IntakeRequestInclude._();
  }

  static IntakeRequestIncludeList includeList({
    _i1.WhereExpressionBuilder<IntakeRequestTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IntakeRequestTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IntakeRequestTable>? orderByList,
    IntakeRequestInclude? include,
  }) {
    return IntakeRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IntakeRequest.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(IntakeRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IntakeRequestImpl extends IntakeRequest {
  _IntakeRequestImpl({
    int? id,
    required int organizationId,
    required String title,
    String? description,
    _i2.IntakeStage? stage,
    double? score,
    String? requesterName,
    String? requesterEmail,
    int? convertedProjectId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         title: title,
         description: description,
         stage: stage,
         score: score,
         requesterName: requesterName,
         requesterEmail: requesterEmail,
         convertedProjectId: convertedProjectId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [IntakeRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IntakeRequest copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? title,
    Object? description = _Undefined,
    _i2.IntakeStage? stage,
    Object? score = _Undefined,
    Object? requesterName = _Undefined,
    Object? requesterEmail = _Undefined,
    Object? convertedProjectId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return IntakeRequest(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      stage: stage ?? this.stage,
      score: score is double? ? score : this.score,
      requesterName: requesterName is String?
          ? requesterName
          : this.requesterName,
      requesterEmail: requesterEmail is String?
          ? requesterEmail
          : this.requesterEmail,
      convertedProjectId: convertedProjectId is int?
          ? convertedProjectId
          : this.convertedProjectId,
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

class IntakeRequestUpdateTable extends _i1.UpdateTable<IntakeRequestTable> {
  IntakeRequestUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<_i2.IntakeStage, _i2.IntakeStage> stage(
    _i2.IntakeStage value,
  ) => _i1.ColumnValue(
    table.stage,
    value,
  );

  _i1.ColumnValue<double, double> score(double? value) => _i1.ColumnValue(
    table.score,
    value,
  );

  _i1.ColumnValue<String, String> requesterName(String? value) =>
      _i1.ColumnValue(
        table.requesterName,
        value,
      );

  _i1.ColumnValue<String, String> requesterEmail(String? value) =>
      _i1.ColumnValue(
        table.requesterEmail,
        value,
      );

  _i1.ColumnValue<int, int> convertedProjectId(int? value) => _i1.ColumnValue(
    table.convertedProjectId,
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

class IntakeRequestTable extends _i1.Table<int?> {
  IntakeRequestTable({super.tableRelation})
    : super(tableName: 'intake_request') {
    updateTable = IntakeRequestUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    stage = _i1.ColumnEnum(
      'stage',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    score = _i1.ColumnDouble(
      'score',
      this,
    );
    requesterName = _i1.ColumnString(
      'requesterName',
      this,
    );
    requesterEmail = _i1.ColumnString(
      'requesterEmail',
      this,
    );
    convertedProjectId = _i1.ColumnInt(
      'convertedProjectId',
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

  late final IntakeRequestUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString title;

  late final _i1.ColumnString description;

  late final _i1.ColumnEnum<_i2.IntakeStage> stage;

  late final _i1.ColumnDouble score;

  late final _i1.ColumnString requesterName;

  late final _i1.ColumnString requesterEmail;

  late final _i1.ColumnInt convertedProjectId;

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
    description,
    stage,
    score,
    requesterName,
    requesterEmail,
    convertedProjectId,
    createdAt,
    updatedAt,
    createdByUserInfoId,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class IntakeRequestInclude extends _i1.IncludeObject {
  IntakeRequestInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => IntakeRequest.t;
}

class IntakeRequestIncludeList extends _i1.IncludeList {
  IntakeRequestIncludeList._({
    _i1.WhereExpressionBuilder<IntakeRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(IntakeRequest.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => IntakeRequest.t;
}

class IntakeRequestRepository {
  const IntakeRequestRepository._();

  /// Returns a list of [IntakeRequest]s matching the given query parameters.
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
  Future<List<IntakeRequest>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IntakeRequestTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IntakeRequestTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IntakeRequestTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<IntakeRequest>(
      where: where?.call(IntakeRequest.t),
      orderBy: orderBy?.call(IntakeRequest.t),
      orderByList: orderByList?.call(IntakeRequest.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [IntakeRequest] matching the given query parameters.
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
  Future<IntakeRequest?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IntakeRequestTable>? where,
    int? offset,
    _i1.OrderByBuilder<IntakeRequestTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IntakeRequestTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<IntakeRequest>(
      where: where?.call(IntakeRequest.t),
      orderBy: orderBy?.call(IntakeRequest.t),
      orderByList: orderByList?.call(IntakeRequest.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [IntakeRequest] by its [id] or null if no such row exists.
  Future<IntakeRequest?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<IntakeRequest>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [IntakeRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [IntakeRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<IntakeRequest>> insert(
    _i1.DatabaseSession session,
    List<IntakeRequest> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<IntakeRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [IntakeRequest] and returns the inserted row.
  ///
  /// The returned [IntakeRequest] will have its `id` field set.
  Future<IntakeRequest> insertRow(
    _i1.DatabaseSession session,
    IntakeRequest row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<IntakeRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [IntakeRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<IntakeRequest>> update(
    _i1.DatabaseSession session,
    List<IntakeRequest> rows, {
    _i1.ColumnSelections<IntakeRequestTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<IntakeRequest>(
      rows,
      columns: columns?.call(IntakeRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IntakeRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<IntakeRequest> updateRow(
    _i1.DatabaseSession session,
    IntakeRequest row, {
    _i1.ColumnSelections<IntakeRequestTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<IntakeRequest>(
      row,
      columns: columns?.call(IntakeRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IntakeRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<IntakeRequest?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<IntakeRequestUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<IntakeRequest>(
      id,
      columnValues: columnValues(IntakeRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [IntakeRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<IntakeRequest>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<IntakeRequestUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<IntakeRequestTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IntakeRequestTable>? orderBy,
    _i1.OrderByListBuilder<IntakeRequestTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<IntakeRequest>(
      columnValues: columnValues(IntakeRequest.t.updateTable),
      where: where(IntakeRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IntakeRequest.t),
      orderByList: orderByList?.call(IntakeRequest.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [IntakeRequest]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<IntakeRequest>> delete(
    _i1.DatabaseSession session,
    List<IntakeRequest> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<IntakeRequest>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [IntakeRequest].
  Future<IntakeRequest> deleteRow(
    _i1.DatabaseSession session,
    IntakeRequest row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<IntakeRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<IntakeRequest>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<IntakeRequestTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<IntakeRequest>(
      where: where(IntakeRequest.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IntakeRequestTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<IntakeRequest>(
      where: where?.call(IntakeRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [IntakeRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<IntakeRequestTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<IntakeRequest>(
      where: where(IntakeRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
