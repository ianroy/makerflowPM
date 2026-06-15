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
import 'enums/partnership_stage.dart' as _i2;

/// External/internal relationship pipeline.
abstract class Partnership
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Partnership._({
    this.id,
    required this.organizationId,
    required this.name,
    _i2.PartnershipStage? stage,
    this.contactName,
    this.contactEmail,
    this.health,
    this.nextFollowUpAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : stage = stage ?? _i2.PartnershipStage.prospect;

  factory Partnership({
    int? id,
    required int organizationId,
    required String name,
    _i2.PartnershipStage? stage,
    String? contactName,
    String? contactEmail,
    String? health,
    DateTime? nextFollowUpAt,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _PartnershipImpl;

  factory Partnership.fromJson(Map<String, dynamic> jsonSerialization) {
    return Partnership(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      stage: jsonSerialization['stage'] == null
          ? null
          : _i2.PartnershipStage.fromJson(
              (jsonSerialization['stage'] as String),
            ),
      contactName: jsonSerialization['contactName'] as String?,
      contactEmail: jsonSerialization['contactEmail'] as String?,
      health: jsonSerialization['health'] as String?,
      nextFollowUpAt: jsonSerialization['nextFollowUpAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextFollowUpAt'],
            ),
      notes: jsonSerialization['notes'] as String?,
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

  static final t = PartnershipTable();

  static const db = PartnershipRepository._();

  @override
  int? id;

  int organizationId;

  String name;

  _i2.PartnershipStage stage;

  String? contactName;

  String? contactEmail;

  String? health;

  DateTime? nextFollowUpAt;

  String? notes;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Partnership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Partnership copyWith({
    int? id,
    int? organizationId,
    String? name,
    _i2.PartnershipStage? stage,
    String? contactName,
    String? contactEmail,
    String? health,
    DateTime? nextFollowUpAt,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Partnership',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      'stage': stage.toJson(),
      if (contactName != null) 'contactName': contactName,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (health != null) 'health': health,
      if (nextFollowUpAt != null) 'nextFollowUpAt': nextFollowUpAt?.toJson(),
      if (notes != null) 'notes': notes,
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
      '__className__': 'Partnership',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      'stage': stage.toJson(),
      if (contactName != null) 'contactName': contactName,
      if (contactEmail != null) 'contactEmail': contactEmail,
      if (health != null) 'health': health,
      if (nextFollowUpAt != null) 'nextFollowUpAt': nextFollowUpAt?.toJson(),
      if (notes != null) 'notes': notes,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static PartnershipInclude include() {
    return PartnershipInclude._();
  }

  static PartnershipIncludeList includeList({
    _i1.WhereExpressionBuilder<PartnershipTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PartnershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PartnershipTable>? orderByList,
    PartnershipInclude? include,
  }) {
    return PartnershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Partnership.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Partnership.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PartnershipImpl extends Partnership {
  _PartnershipImpl({
    int? id,
    required int organizationId,
    required String name,
    _i2.PartnershipStage? stage,
    String? contactName,
    String? contactEmail,
    String? health,
    DateTime? nextFollowUpAt,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         stage: stage,
         contactName: contactName,
         contactEmail: contactEmail,
         health: health,
         nextFollowUpAt: nextFollowUpAt,
         notes: notes,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [Partnership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Partnership copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    _i2.PartnershipStage? stage,
    Object? contactName = _Undefined,
    Object? contactEmail = _Undefined,
    Object? health = _Undefined,
    Object? nextFollowUpAt = _Undefined,
    Object? notes = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return Partnership(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      stage: stage ?? this.stage,
      contactName: contactName is String? ? contactName : this.contactName,
      contactEmail: contactEmail is String? ? contactEmail : this.contactEmail,
      health: health is String? ? health : this.health,
      nextFollowUpAt: nextFollowUpAt is DateTime?
          ? nextFollowUpAt
          : this.nextFollowUpAt,
      notes: notes is String? ? notes : this.notes,
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

class PartnershipUpdateTable extends _i1.UpdateTable<PartnershipTable> {
  PartnershipUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<_i2.PartnershipStage, _i2.PartnershipStage> stage(
    _i2.PartnershipStage value,
  ) => _i1.ColumnValue(
    table.stage,
    value,
  );

  _i1.ColumnValue<String, String> contactName(String? value) => _i1.ColumnValue(
    table.contactName,
    value,
  );

  _i1.ColumnValue<String, String> contactEmail(String? value) =>
      _i1.ColumnValue(
        table.contactEmail,
        value,
      );

  _i1.ColumnValue<String, String> health(String? value) => _i1.ColumnValue(
    table.health,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> nextFollowUpAt(DateTime? value) =>
      _i1.ColumnValue(
        table.nextFollowUpAt,
        value,
      );

  _i1.ColumnValue<String, String> notes(String? value) => _i1.ColumnValue(
    table.notes,
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

class PartnershipTable extends _i1.Table<int?> {
  PartnershipTable({super.tableRelation}) : super(tableName: 'partnership') {
    updateTable = PartnershipUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    stage = _i1.ColumnEnum(
      'stage',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    contactName = _i1.ColumnString(
      'contactName',
      this,
    );
    contactEmail = _i1.ColumnString(
      'contactEmail',
      this,
    );
    health = _i1.ColumnString(
      'health',
      this,
    );
    nextFollowUpAt = _i1.ColumnDateTime(
      'nextFollowUpAt',
      this,
    );
    notes = _i1.ColumnString(
      'notes',
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

  late final PartnershipUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString name;

  late final _i1.ColumnEnum<_i2.PartnershipStage> stage;

  late final _i1.ColumnString contactName;

  late final _i1.ColumnString contactEmail;

  late final _i1.ColumnString health;

  late final _i1.ColumnDateTime nextFollowUpAt;

  late final _i1.ColumnString notes;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnInt createdByUserInfoId;

  late final _i1.ColumnDateTime deletedAt;

  late final _i1.ColumnInt deletedByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    name,
    stage,
    contactName,
    contactEmail,
    health,
    nextFollowUpAt,
    notes,
    createdAt,
    updatedAt,
    createdByUserInfoId,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class PartnershipInclude extends _i1.IncludeObject {
  PartnershipInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Partnership.t;
}

class PartnershipIncludeList extends _i1.IncludeList {
  PartnershipIncludeList._({
    _i1.WhereExpressionBuilder<PartnershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Partnership.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Partnership.t;
}

class PartnershipRepository {
  const PartnershipRepository._();

  /// Returns a list of [Partnership]s matching the given query parameters.
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
  Future<List<Partnership>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PartnershipTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PartnershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PartnershipTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Partnership>(
      where: where?.call(Partnership.t),
      orderBy: orderBy?.call(Partnership.t),
      orderByList: orderByList?.call(Partnership.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Partnership] matching the given query parameters.
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
  Future<Partnership?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PartnershipTable>? where,
    int? offset,
    _i1.OrderByBuilder<PartnershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PartnershipTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Partnership>(
      where: where?.call(Partnership.t),
      orderBy: orderBy?.call(Partnership.t),
      orderByList: orderByList?.call(Partnership.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Partnership] by its [id] or null if no such row exists.
  Future<Partnership?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Partnership>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Partnership]s in the list and returns the inserted rows.
  ///
  /// The returned [Partnership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Partnership>> insert(
    _i1.DatabaseSession session,
    List<Partnership> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Partnership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Partnership] and returns the inserted row.
  ///
  /// The returned [Partnership] will have its `id` field set.
  Future<Partnership> insertRow(
    _i1.DatabaseSession session,
    Partnership row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Partnership>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Partnership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Partnership>> update(
    _i1.DatabaseSession session,
    List<Partnership> rows, {
    _i1.ColumnSelections<PartnershipTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Partnership>(
      rows,
      columns: columns?.call(Partnership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Partnership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Partnership> updateRow(
    _i1.DatabaseSession session,
    Partnership row, {
    _i1.ColumnSelections<PartnershipTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Partnership>(
      row,
      columns: columns?.call(Partnership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Partnership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Partnership?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PartnershipUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Partnership>(
      id,
      columnValues: columnValues(Partnership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Partnership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Partnership>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PartnershipUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PartnershipTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PartnershipTable>? orderBy,
    _i1.OrderByListBuilder<PartnershipTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Partnership>(
      columnValues: columnValues(Partnership.t.updateTable),
      where: where(Partnership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Partnership.t),
      orderByList: orderByList?.call(Partnership.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Partnership]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Partnership>> delete(
    _i1.DatabaseSession session,
    List<Partnership> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Partnership>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Partnership].
  Future<Partnership> deleteRow(
    _i1.DatabaseSession session,
    Partnership row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Partnership>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Partnership>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PartnershipTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Partnership>(
      where: where(Partnership.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PartnershipTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Partnership>(
      where: where?.call(Partnership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Partnership] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PartnershipTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Partnership>(
      where: where(Partnership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
