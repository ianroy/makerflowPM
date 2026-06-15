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
import 'enums/consumable_status.dart' as _i2;

/// Per-space stock + reorder tracking.
abstract class Consumable
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Consumable._({
    this.id,
    required this.organizationId,
    required this.name,
    this.unit,
    double? quantityOnHand,
    double? reorderPoint,
    _i2.ConsumableStatus? status,
    this.spaceId,
    this.category,
    this.clientUuid,
    int? version,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : quantityOnHand = quantityOnHand ?? 0.0,
       reorderPoint = reorderPoint ?? 0.0,
       status = status ?? _i2.ConsumableStatus.inStock,
       version = version ?? 1;

  factory Consumable({
    int? id,
    required int organizationId,
    required String name,
    String? unit,
    double? quantityOnHand,
    double? reorderPoint,
    _i2.ConsumableStatus? status,
    int? spaceId,
    String? category,
    String? clientUuid,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _ConsumableImpl;

  factory Consumable.fromJson(Map<String, dynamic> jsonSerialization) {
    return Consumable(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      unit: jsonSerialization['unit'] as String?,
      quantityOnHand: (jsonSerialization['quantityOnHand'] as num?)?.toDouble(),
      reorderPoint: (jsonSerialization['reorderPoint'] as num?)?.toDouble(),
      status: jsonSerialization['status'] == null
          ? null
          : _i2.ConsumableStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      spaceId: jsonSerialization['spaceId'] as int?,
      category: jsonSerialization['category'] as String?,
      clientUuid: jsonSerialization['clientUuid'] as String?,
      version: jsonSerialization['version'] as int?,
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

  static final t = ConsumableTable();

  static const db = ConsumableRepository._();

  @override
  int? id;

  int organizationId;

  String name;

  String? unit;

  double quantityOnHand;

  double reorderPoint;

  _i2.ConsumableStatus status;

  int? spaceId;

  String? category;

  String? clientUuid;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Consumable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Consumable copyWith({
    int? id,
    int? organizationId,
    String? name,
    String? unit,
    double? quantityOnHand,
    double? reorderPoint,
    _i2.ConsumableStatus? status,
    int? spaceId,
    String? category,
    String? clientUuid,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Consumable',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (unit != null) 'unit': unit,
      'quantityOnHand': quantityOnHand,
      'reorderPoint': reorderPoint,
      'status': status.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      if (category != null) 'category': category,
      if (clientUuid != null) 'clientUuid': clientUuid,
      'version': version,
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
      '__className__': 'Consumable',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (unit != null) 'unit': unit,
      'quantityOnHand': quantityOnHand,
      'reorderPoint': reorderPoint,
      'status': status.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      if (category != null) 'category': category,
      if (clientUuid != null) 'clientUuid': clientUuid,
      'version': version,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static ConsumableInclude include() {
    return ConsumableInclude._();
  }

  static ConsumableIncludeList includeList({
    _i1.WhereExpressionBuilder<ConsumableTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumableTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumableTable>? orderByList,
    ConsumableInclude? include,
  }) {
    return ConsumableIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Consumable.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Consumable.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ConsumableImpl extends Consumable {
  _ConsumableImpl({
    int? id,
    required int organizationId,
    required String name,
    String? unit,
    double? quantityOnHand,
    double? reorderPoint,
    _i2.ConsumableStatus? status,
    int? spaceId,
    String? category,
    String? clientUuid,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         unit: unit,
         quantityOnHand: quantityOnHand,
         reorderPoint: reorderPoint,
         status: status,
         spaceId: spaceId,
         category: category,
         clientUuid: clientUuid,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [Consumable]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Consumable copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    Object? unit = _Undefined,
    double? quantityOnHand,
    double? reorderPoint,
    _i2.ConsumableStatus? status,
    Object? spaceId = _Undefined,
    Object? category = _Undefined,
    Object? clientUuid = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return Consumable(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      unit: unit is String? ? unit : this.unit,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      status: status ?? this.status,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
      category: category is String? ? category : this.category,
      clientUuid: clientUuid is String? ? clientUuid : this.clientUuid,
      version: version ?? this.version,
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

class ConsumableUpdateTable extends _i1.UpdateTable<ConsumableTable> {
  ConsumableUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> unit(String? value) => _i1.ColumnValue(
    table.unit,
    value,
  );

  _i1.ColumnValue<double, double> quantityOnHand(double value) =>
      _i1.ColumnValue(
        table.quantityOnHand,
        value,
      );

  _i1.ColumnValue<double, double> reorderPoint(double value) => _i1.ColumnValue(
    table.reorderPoint,
    value,
  );

  _i1.ColumnValue<_i2.ConsumableStatus, _i2.ConsumableStatus> status(
    _i2.ConsumableStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<int, int> spaceId(int? value) => _i1.ColumnValue(
    table.spaceId,
    value,
  );

  _i1.ColumnValue<String, String> category(String? value) => _i1.ColumnValue(
    table.category,
    value,
  );

  _i1.ColumnValue<String, String> clientUuid(String? value) => _i1.ColumnValue(
    table.clientUuid,
    value,
  );

  _i1.ColumnValue<int, int> version(int value) => _i1.ColumnValue(
    table.version,
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

class ConsumableTable extends _i1.Table<int?> {
  ConsumableTable({super.tableRelation}) : super(tableName: 'consumable') {
    updateTable = ConsumableUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    unit = _i1.ColumnString(
      'unit',
      this,
    );
    quantityOnHand = _i1.ColumnDouble(
      'quantityOnHand',
      this,
      hasDefault: true,
    );
    reorderPoint = _i1.ColumnDouble(
      'reorderPoint',
      this,
      hasDefault: true,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    spaceId = _i1.ColumnInt(
      'spaceId',
      this,
    );
    category = _i1.ColumnString(
      'category',
      this,
    );
    clientUuid = _i1.ColumnString(
      'clientUuid',
      this,
    );
    version = _i1.ColumnInt(
      'version',
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

  late final ConsumableUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString unit;

  late final _i1.ColumnDouble quantityOnHand;

  late final _i1.ColumnDouble reorderPoint;

  late final _i1.ColumnEnum<_i2.ConsumableStatus> status;

  late final _i1.ColumnInt spaceId;

  late final _i1.ColumnString category;

  late final _i1.ColumnString clientUuid;

  late final _i1.ColumnInt version;

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
    unit,
    quantityOnHand,
    reorderPoint,
    status,
    spaceId,
    category,
    clientUuid,
    version,
    createdAt,
    updatedAt,
    createdByUserInfoId,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class ConsumableInclude extends _i1.IncludeObject {
  ConsumableInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Consumable.t;
}

class ConsumableIncludeList extends _i1.IncludeList {
  ConsumableIncludeList._({
    _i1.WhereExpressionBuilder<ConsumableTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Consumable.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Consumable.t;
}

class ConsumableRepository {
  const ConsumableRepository._();

  /// Returns a list of [Consumable]s matching the given query parameters.
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
  Future<List<Consumable>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ConsumableTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumableTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumableTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Consumable>(
      where: where?.call(Consumable.t),
      orderBy: orderBy?.call(Consumable.t),
      orderByList: orderByList?.call(Consumable.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Consumable] matching the given query parameters.
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
  Future<Consumable?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ConsumableTable>? where,
    int? offset,
    _i1.OrderByBuilder<ConsumableTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ConsumableTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Consumable>(
      where: where?.call(Consumable.t),
      orderBy: orderBy?.call(Consumable.t),
      orderByList: orderByList?.call(Consumable.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Consumable] by its [id] or null if no such row exists.
  Future<Consumable?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Consumable>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Consumable]s in the list and returns the inserted rows.
  ///
  /// The returned [Consumable]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Consumable>> insert(
    _i1.DatabaseSession session,
    List<Consumable> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Consumable>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Consumable] and returns the inserted row.
  ///
  /// The returned [Consumable] will have its `id` field set.
  Future<Consumable> insertRow(
    _i1.DatabaseSession session,
    Consumable row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Consumable>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Consumable]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Consumable>> update(
    _i1.DatabaseSession session,
    List<Consumable> rows, {
    _i1.ColumnSelections<ConsumableTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Consumable>(
      rows,
      columns: columns?.call(Consumable.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Consumable]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Consumable> updateRow(
    _i1.DatabaseSession session,
    Consumable row, {
    _i1.ColumnSelections<ConsumableTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Consumable>(
      row,
      columns: columns?.call(Consumable.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Consumable] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Consumable?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ConsumableUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Consumable>(
      id,
      columnValues: columnValues(Consumable.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Consumable]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Consumable>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ConsumableUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ConsumableTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ConsumableTable>? orderBy,
    _i1.OrderByListBuilder<ConsumableTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Consumable>(
      columnValues: columnValues(Consumable.t.updateTable),
      where: where(Consumable.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Consumable.t),
      orderByList: orderByList?.call(Consumable.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Consumable]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Consumable>> delete(
    _i1.DatabaseSession session,
    List<Consumable> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Consumable>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Consumable].
  Future<Consumable> deleteRow(
    _i1.DatabaseSession session,
    Consumable row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Consumable>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Consumable>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ConsumableTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Consumable>(
      where: where(Consumable.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ConsumableTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Consumable>(
      where: where?.call(Consumable.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Consumable] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ConsumableTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Consumable>(
      where: where(Consumable.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
