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
import 'enums/equipment_status.dart' as _i2;

/// Trackable equipment with maintenance + certification state.
abstract class EquipmentAsset
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  EquipmentAsset._({
    this.id,
    required this.organizationId,
    required this.name,
    this.assetTag,
    _i2.EquipmentStatus? status,
    this.spaceId,
    bool? certificationRequired,
    this.lastMaintenanceAt,
    this.nextMaintenanceAt,
    this.notes,
    this.clientUuid,
    int? version,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : status = status ?? _i2.EquipmentStatus.operational,
       certificationRequired = certificationRequired ?? false,
       version = version ?? 1;

  factory EquipmentAsset({
    int? id,
    required int organizationId,
    required String name,
    String? assetTag,
    _i2.EquipmentStatus? status,
    int? spaceId,
    bool? certificationRequired,
    DateTime? lastMaintenanceAt,
    DateTime? nextMaintenanceAt,
    String? notes,
    String? clientUuid,
    int? version,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _EquipmentAssetImpl;

  factory EquipmentAsset.fromJson(Map<String, dynamic> jsonSerialization) {
    return EquipmentAsset(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      assetTag: jsonSerialization['assetTag'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _i2.EquipmentStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      spaceId: jsonSerialization['spaceId'] as int?,
      certificationRequired: jsonSerialization['certificationRequired'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['certificationRequired'],
            ),
      lastMaintenanceAt: jsonSerialization['lastMaintenanceAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastMaintenanceAt'],
            ),
      nextMaintenanceAt: jsonSerialization['nextMaintenanceAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextMaintenanceAt'],
            ),
      notes: jsonSerialization['notes'] as String?,
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

  static final t = EquipmentAssetTable();

  static const db = EquipmentAssetRepository._();

  @override
  int? id;

  int organizationId;

  String name;

  String? assetTag;

  _i2.EquipmentStatus status;

  int? spaceId;

  bool certificationRequired;

  DateTime? lastMaintenanceAt;

  DateTime? nextMaintenanceAt;

  String? notes;

  String? clientUuid;

  int version;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [EquipmentAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EquipmentAsset copyWith({
    int? id,
    int? organizationId,
    String? name,
    String? assetTag,
    _i2.EquipmentStatus? status,
    int? spaceId,
    bool? certificationRequired,
    DateTime? lastMaintenanceAt,
    DateTime? nextMaintenanceAt,
    String? notes,
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
      '__className__': 'EquipmentAsset',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (assetTag != null) 'assetTag': assetTag,
      'status': status.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      'certificationRequired': certificationRequired,
      if (lastMaintenanceAt != null)
        'lastMaintenanceAt': lastMaintenanceAt?.toJson(),
      if (nextMaintenanceAt != null)
        'nextMaintenanceAt': nextMaintenanceAt?.toJson(),
      if (notes != null) 'notes': notes,
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
      '__className__': 'EquipmentAsset',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (assetTag != null) 'assetTag': assetTag,
      'status': status.toJson(),
      if (spaceId != null) 'spaceId': spaceId,
      'certificationRequired': certificationRequired,
      if (lastMaintenanceAt != null)
        'lastMaintenanceAt': lastMaintenanceAt?.toJson(),
      if (nextMaintenanceAt != null)
        'nextMaintenanceAt': nextMaintenanceAt?.toJson(),
      if (notes != null) 'notes': notes,
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

  static EquipmentAssetInclude include() {
    return EquipmentAssetInclude._();
  }

  static EquipmentAssetIncludeList includeList({
    _i1.WhereExpressionBuilder<EquipmentAssetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EquipmentAssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EquipmentAssetTable>? orderByList,
    EquipmentAssetInclude? include,
  }) {
    return EquipmentAssetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EquipmentAsset.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(EquipmentAsset.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EquipmentAssetImpl extends EquipmentAsset {
  _EquipmentAssetImpl({
    int? id,
    required int organizationId,
    required String name,
    String? assetTag,
    _i2.EquipmentStatus? status,
    int? spaceId,
    bool? certificationRequired,
    DateTime? lastMaintenanceAt,
    DateTime? nextMaintenanceAt,
    String? notes,
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
         assetTag: assetTag,
         status: status,
         spaceId: spaceId,
         certificationRequired: certificationRequired,
         lastMaintenanceAt: lastMaintenanceAt,
         nextMaintenanceAt: nextMaintenanceAt,
         notes: notes,
         clientUuid: clientUuid,
         version: version,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [EquipmentAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EquipmentAsset copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    Object? assetTag = _Undefined,
    _i2.EquipmentStatus? status,
    Object? spaceId = _Undefined,
    bool? certificationRequired,
    Object? lastMaintenanceAt = _Undefined,
    Object? nextMaintenanceAt = _Undefined,
    Object? notes = _Undefined,
    Object? clientUuid = _Undefined,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return EquipmentAsset(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      assetTag: assetTag is String? ? assetTag : this.assetTag,
      status: status ?? this.status,
      spaceId: spaceId is int? ? spaceId : this.spaceId,
      certificationRequired:
          certificationRequired ?? this.certificationRequired,
      lastMaintenanceAt: lastMaintenanceAt is DateTime?
          ? lastMaintenanceAt
          : this.lastMaintenanceAt,
      nextMaintenanceAt: nextMaintenanceAt is DateTime?
          ? nextMaintenanceAt
          : this.nextMaintenanceAt,
      notes: notes is String? ? notes : this.notes,
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

class EquipmentAssetUpdateTable extends _i1.UpdateTable<EquipmentAssetTable> {
  EquipmentAssetUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> assetTag(String? value) => _i1.ColumnValue(
    table.assetTag,
    value,
  );

  _i1.ColumnValue<_i2.EquipmentStatus, _i2.EquipmentStatus> status(
    _i2.EquipmentStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<int, int> spaceId(int? value) => _i1.ColumnValue(
    table.spaceId,
    value,
  );

  _i1.ColumnValue<bool, bool> certificationRequired(bool value) =>
      _i1.ColumnValue(
        table.certificationRequired,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> lastMaintenanceAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastMaintenanceAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> nextMaintenanceAt(DateTime? value) =>
      _i1.ColumnValue(
        table.nextMaintenanceAt,
        value,
      );

  _i1.ColumnValue<String, String> notes(String? value) => _i1.ColumnValue(
    table.notes,
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

class EquipmentAssetTable extends _i1.Table<int?> {
  EquipmentAssetTable({super.tableRelation})
    : super(tableName: 'equipment_asset') {
    updateTable = EquipmentAssetUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    assetTag = _i1.ColumnString(
      'assetTag',
      this,
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
    certificationRequired = _i1.ColumnBool(
      'certificationRequired',
      this,
      hasDefault: true,
    );
    lastMaintenanceAt = _i1.ColumnDateTime(
      'lastMaintenanceAt',
      this,
    );
    nextMaintenanceAt = _i1.ColumnDateTime(
      'nextMaintenanceAt',
      this,
    );
    notes = _i1.ColumnString(
      'notes',
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

  late final EquipmentAssetUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString assetTag;

  late final _i1.ColumnEnum<_i2.EquipmentStatus> status;

  late final _i1.ColumnInt spaceId;

  late final _i1.ColumnBool certificationRequired;

  late final _i1.ColumnDateTime lastMaintenanceAt;

  late final _i1.ColumnDateTime nextMaintenanceAt;

  late final _i1.ColumnString notes;

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
    assetTag,
    status,
    spaceId,
    certificationRequired,
    lastMaintenanceAt,
    nextMaintenanceAt,
    notes,
    clientUuid,
    version,
    createdAt,
    updatedAt,
    createdByUserInfoId,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class EquipmentAssetInclude extends _i1.IncludeObject {
  EquipmentAssetInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => EquipmentAsset.t;
}

class EquipmentAssetIncludeList extends _i1.IncludeList {
  EquipmentAssetIncludeList._({
    _i1.WhereExpressionBuilder<EquipmentAssetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EquipmentAsset.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => EquipmentAsset.t;
}

class EquipmentAssetRepository {
  const EquipmentAssetRepository._();

  /// Returns a list of [EquipmentAsset]s matching the given query parameters.
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
  Future<List<EquipmentAsset>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EquipmentAssetTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EquipmentAssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EquipmentAssetTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EquipmentAsset>(
      where: where?.call(EquipmentAsset.t),
      orderBy: orderBy?.call(EquipmentAsset.t),
      orderByList: orderByList?.call(EquipmentAsset.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EquipmentAsset] matching the given query parameters.
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
  Future<EquipmentAsset?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EquipmentAssetTable>? where,
    int? offset,
    _i1.OrderByBuilder<EquipmentAssetTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EquipmentAssetTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EquipmentAsset>(
      where: where?.call(EquipmentAsset.t),
      orderBy: orderBy?.call(EquipmentAsset.t),
      orderByList: orderByList?.call(EquipmentAsset.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EquipmentAsset] by its [id] or null if no such row exists.
  Future<EquipmentAsset?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EquipmentAsset>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EquipmentAsset]s in the list and returns the inserted rows.
  ///
  /// The returned [EquipmentAsset]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<EquipmentAsset>> insert(
    _i1.DatabaseSession session,
    List<EquipmentAsset> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<EquipmentAsset>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [EquipmentAsset] and returns the inserted row.
  ///
  /// The returned [EquipmentAsset] will have its `id` field set.
  Future<EquipmentAsset> insertRow(
    _i1.DatabaseSession session,
    EquipmentAsset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EquipmentAsset>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EquipmentAsset]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EquipmentAsset>> update(
    _i1.DatabaseSession session,
    List<EquipmentAsset> rows, {
    _i1.ColumnSelections<EquipmentAssetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EquipmentAsset>(
      rows,
      columns: columns?.call(EquipmentAsset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EquipmentAsset]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EquipmentAsset> updateRow(
    _i1.DatabaseSession session,
    EquipmentAsset row, {
    _i1.ColumnSelections<EquipmentAssetTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<EquipmentAsset>(
      row,
      columns: columns?.call(EquipmentAsset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EquipmentAsset] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EquipmentAsset?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<EquipmentAssetUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<EquipmentAsset>(
      id,
      columnValues: columnValues(EquipmentAsset.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EquipmentAsset]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<EquipmentAsset>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<EquipmentAssetUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<EquipmentAssetTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EquipmentAssetTable>? orderBy,
    _i1.OrderByListBuilder<EquipmentAssetTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<EquipmentAsset>(
      columnValues: columnValues(EquipmentAsset.t.updateTable),
      where: where(EquipmentAsset.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EquipmentAsset.t),
      orderByList: orderByList?.call(EquipmentAsset.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EquipmentAsset]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EquipmentAsset>> delete(
    _i1.DatabaseSession session,
    List<EquipmentAsset> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EquipmentAsset>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EquipmentAsset].
  Future<EquipmentAsset> deleteRow(
    _i1.DatabaseSession session,
    EquipmentAsset row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EquipmentAsset>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EquipmentAsset>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EquipmentAssetTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EquipmentAsset>(
      where: where(EquipmentAsset.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EquipmentAssetTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EquipmentAsset>(
      where: where?.call(EquipmentAsset.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EquipmentAsset] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EquipmentAssetTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EquipmentAsset>(
      where: where(EquipmentAsset.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
