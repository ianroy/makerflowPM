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

/// Per-org custom field definition applied to an entity type.
abstract class FieldConfig
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  FieldConfig._({
    this.id,
    required this.organizationId,
    required this.entityType,
    required this.key,
    required this.label,
    required this.fieldType,
    this.optionsJson,
    bool? required,
    double? sortOrder,
    required this.createdAt,
    required this.updatedAt,
  }) : required = required ?? false,
       sortOrder = sortOrder ?? 0.0;

  factory FieldConfig({
    int? id,
    required int organizationId,
    required String entityType,
    required String key,
    required String label,
    required String fieldType,
    String? optionsJson,
    bool? required,
    double? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FieldConfigImpl;

  factory FieldConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return FieldConfig(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      entityType: jsonSerialization['entityType'] as String,
      key: jsonSerialization['key'] as String,
      label: jsonSerialization['label'] as String,
      fieldType: jsonSerialization['fieldType'] as String,
      optionsJson: jsonSerialization['optionsJson'] as String?,
      required: jsonSerialization['required'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['required']),
      sortOrder: (jsonSerialization['sortOrder'] as num?)?.toDouble(),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = FieldConfigTable();

  static const db = FieldConfigRepository._();

  @override
  int? id;

  int organizationId;

  String entityType;

  String key;

  String label;

  String fieldType;

  String? optionsJson;

  bool required;

  double sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [FieldConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  FieldConfig copyWith({
    int? id,
    int? organizationId,
    String? entityType,
    String? key,
    String? label,
    String? fieldType,
    String? optionsJson,
    bool? required,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'FieldConfig',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'key': key,
      'label': label,
      'fieldType': fieldType,
      if (optionsJson != null) 'optionsJson': optionsJson,
      'required': required,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'FieldConfig',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'key': key,
      'label': label,
      'fieldType': fieldType,
      if (optionsJson != null) 'optionsJson': optionsJson,
      'required': required,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static FieldConfigInclude include() {
    return FieldConfigInclude._();
  }

  static FieldConfigIncludeList includeList({
    _i1.WhereExpressionBuilder<FieldConfigTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FieldConfigTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FieldConfigTable>? orderByList,
    FieldConfigInclude? include,
  }) {
    return FieldConfigIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FieldConfig.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(FieldConfig.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FieldConfigImpl extends FieldConfig {
  _FieldConfigImpl({
    int? id,
    required int organizationId,
    required String entityType,
    required String key,
    required String label,
    required String fieldType,
    String? optionsJson,
    bool? required,
    double? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         entityType: entityType,
         key: key,
         label: label,
         fieldType: fieldType,
         optionsJson: optionsJson,
         required: required,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [FieldConfig]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  FieldConfig copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? entityType,
    String? key,
    String? label,
    String? fieldType,
    Object? optionsJson = _Undefined,
    bool? required,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FieldConfig(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      entityType: entityType ?? this.entityType,
      key: key ?? this.key,
      label: label ?? this.label,
      fieldType: fieldType ?? this.fieldType,
      optionsJson: optionsJson is String? ? optionsJson : this.optionsJson,
      required: required ?? this.required,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FieldConfigUpdateTable extends _i1.UpdateTable<FieldConfigTable> {
  FieldConfigUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> entityType(String value) => _i1.ColumnValue(
    table.entityType,
    value,
  );

  _i1.ColumnValue<String, String> key(String value) => _i1.ColumnValue(
    table.key,
    value,
  );

  _i1.ColumnValue<String, String> label(String value) => _i1.ColumnValue(
    table.label,
    value,
  );

  _i1.ColumnValue<String, String> fieldType(String value) => _i1.ColumnValue(
    table.fieldType,
    value,
  );

  _i1.ColumnValue<String, String> optionsJson(String? value) => _i1.ColumnValue(
    table.optionsJson,
    value,
  );

  _i1.ColumnValue<bool, bool> required(bool value) => _i1.ColumnValue(
    table.required,
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
}

class FieldConfigTable extends _i1.Table<int?> {
  FieldConfigTable({super.tableRelation}) : super(tableName: 'field_config') {
    updateTable = FieldConfigUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    entityType = _i1.ColumnString(
      'entityType',
      this,
    );
    key = _i1.ColumnString(
      'key',
      this,
    );
    label = _i1.ColumnString(
      'label',
      this,
    );
    fieldType = _i1.ColumnString(
      'fieldType',
      this,
    );
    optionsJson = _i1.ColumnString(
      'optionsJson',
      this,
    );
    required = _i1.ColumnBool(
      'required',
      this,
      hasDefault: true,
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
  }

  late final FieldConfigUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString entityType;

  late final _i1.ColumnString key;

  late final _i1.ColumnString label;

  late final _i1.ColumnString fieldType;

  late final _i1.ColumnString optionsJson;

  late final _i1.ColumnBool required;

  late final _i1.ColumnDouble sortOrder;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    entityType,
    key,
    label,
    fieldType,
    optionsJson,
    required,
    sortOrder,
    createdAt,
    updatedAt,
  ];
}

class FieldConfigInclude extends _i1.IncludeObject {
  FieldConfigInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => FieldConfig.t;
}

class FieldConfigIncludeList extends _i1.IncludeList {
  FieldConfigIncludeList._({
    _i1.WhereExpressionBuilder<FieldConfigTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(FieldConfig.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => FieldConfig.t;
}

class FieldConfigRepository {
  const FieldConfigRepository._();

  /// Returns a list of [FieldConfig]s matching the given query parameters.
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
  Future<List<FieldConfig>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FieldConfigTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FieldConfigTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FieldConfigTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<FieldConfig>(
      where: where?.call(FieldConfig.t),
      orderBy: orderBy?.call(FieldConfig.t),
      orderByList: orderByList?.call(FieldConfig.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [FieldConfig] matching the given query parameters.
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
  Future<FieldConfig?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FieldConfigTable>? where,
    int? offset,
    _i1.OrderByBuilder<FieldConfigTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FieldConfigTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<FieldConfig>(
      where: where?.call(FieldConfig.t),
      orderBy: orderBy?.call(FieldConfig.t),
      orderByList: orderByList?.call(FieldConfig.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [FieldConfig] by its [id] or null if no such row exists.
  Future<FieldConfig?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<FieldConfig>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [FieldConfig]s in the list and returns the inserted rows.
  ///
  /// The returned [FieldConfig]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<FieldConfig>> insert(
    _i1.DatabaseSession session,
    List<FieldConfig> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<FieldConfig>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [FieldConfig] and returns the inserted row.
  ///
  /// The returned [FieldConfig] will have its `id` field set.
  Future<FieldConfig> insertRow(
    _i1.DatabaseSession session,
    FieldConfig row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<FieldConfig>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [FieldConfig]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<FieldConfig>> update(
    _i1.DatabaseSession session,
    List<FieldConfig> rows, {
    _i1.ColumnSelections<FieldConfigTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<FieldConfig>(
      rows,
      columns: columns?.call(FieldConfig.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FieldConfig]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<FieldConfig> updateRow(
    _i1.DatabaseSession session,
    FieldConfig row, {
    _i1.ColumnSelections<FieldConfigTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<FieldConfig>(
      row,
      columns: columns?.call(FieldConfig.t),
      transaction: transaction,
    );
  }

  /// Updates a single [FieldConfig] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<FieldConfig?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<FieldConfigUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<FieldConfig>(
      id,
      columnValues: columnValues(FieldConfig.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [FieldConfig]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<FieldConfig>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<FieldConfigUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<FieldConfigTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FieldConfigTable>? orderBy,
    _i1.OrderByListBuilder<FieldConfigTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<FieldConfig>(
      columnValues: columnValues(FieldConfig.t.updateTable),
      where: where(FieldConfig.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(FieldConfig.t),
      orderByList: orderByList?.call(FieldConfig.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [FieldConfig]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<FieldConfig>> delete(
    _i1.DatabaseSession session,
    List<FieldConfig> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<FieldConfig>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [FieldConfig].
  Future<FieldConfig> deleteRow(
    _i1.DatabaseSession session,
    FieldConfig row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<FieldConfig>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<FieldConfig>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<FieldConfigTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<FieldConfig>(
      where: where(FieldConfig.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<FieldConfigTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<FieldConfig>(
      where: where?.call(FieldConfig.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [FieldConfig] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<FieldConfigTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<FieldConfig>(
      where: where(FieldConfig.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
