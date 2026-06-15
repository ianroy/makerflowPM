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
import 'enums/attachment_kind.dart' as _i2;

/// Object-store metadata for an uploaded file (supersedes blob storage in the
/// legacy meeting_item_files). Polymorphic via entityType+entityId. altText
/// is required for images (WCAG 1.1.1).
abstract class Attachment
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Attachment._({
    this.id,
    required this.organizationId,
    required this.entityType,
    required this.entityId,
    _i2.AttachmentKind? kind,
    required this.filename,
    required this.contentType,
    required this.bytes,
    required this.storageKey,
    this.altText,
    required this.createdAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : kind = kind ?? _i2.AttachmentKind.other;

  factory Attachment({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    _i2.AttachmentKind? kind,
    required String filename,
    required String contentType,
    required int bytes,
    required String storageKey,
    String? altText,
    required DateTime createdAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _AttachmentImpl;

  factory Attachment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Attachment(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as int,
      kind: jsonSerialization['kind'] == null
          ? null
          : _i2.AttachmentKind.fromJson((jsonSerialization['kind'] as String)),
      filename: jsonSerialization['filename'] as String,
      contentType: jsonSerialization['contentType'] as String,
      bytes: jsonSerialization['bytes'] as int,
      storageKey: jsonSerialization['storageKey'] as String,
      altText: jsonSerialization['altText'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      createdByUserInfoId: jsonSerialization['createdByUserInfoId'] as int?,
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      deletedByUserInfoId: jsonSerialization['deletedByUserInfoId'] as int?,
    );
  }

  static final t = AttachmentTable();

  static const db = AttachmentRepository._();

  @override
  int? id;

  int organizationId;

  String entityType;

  int entityId;

  _i2.AttachmentKind kind;

  String filename;

  String contentType;

  int bytes;

  String storageKey;

  String? altText;

  DateTime createdAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Attachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Attachment copyWith({
    int? id,
    int? organizationId,
    String? entityType,
    int? entityId,
    _i2.AttachmentKind? kind,
    String? filename,
    String? contentType,
    int? bytes,
    String? storageKey,
    String? altText,
    DateTime? createdAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Attachment',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'entityId': entityId,
      'kind': kind.toJson(),
      'filename': filename,
      'contentType': contentType,
      'bytes': bytes,
      'storageKey': storageKey,
      if (altText != null) 'altText': altText,
      'createdAt': createdAt.toJson(),
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
      '__className__': 'Attachment',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'entityType': entityType,
      'entityId': entityId,
      'kind': kind.toJson(),
      'filename': filename,
      'contentType': contentType,
      'bytes': bytes,
      'storageKey': storageKey,
      if (altText != null) 'altText': altText,
      'createdAt': createdAt.toJson(),
      if (createdByUserInfoId != null)
        'createdByUserInfoId': createdByUserInfoId,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (deletedByUserInfoId != null)
        'deletedByUserInfoId': deletedByUserInfoId,
    };
  }

  static AttachmentInclude include() {
    return AttachmentInclude._();
  }

  static AttachmentIncludeList includeList({
    _i1.WhereExpressionBuilder<AttachmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AttachmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AttachmentTable>? orderByList,
    AttachmentInclude? include,
  }) {
    return AttachmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Attachment.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Attachment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AttachmentImpl extends Attachment {
  _AttachmentImpl({
    int? id,
    required int organizationId,
    required String entityType,
    required int entityId,
    _i2.AttachmentKind? kind,
    required String filename,
    required String contentType,
    required int bytes,
    required String storageKey,
    String? altText,
    required DateTime createdAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         entityType: entityType,
         entityId: entityId,
         kind: kind,
         filename: filename,
         contentType: contentType,
         bytes: bytes,
         storageKey: storageKey,
         altText: altText,
         createdAt: createdAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [Attachment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Attachment copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? entityType,
    int? entityId,
    _i2.AttachmentKind? kind,
    String? filename,
    String? contentType,
    int? bytes,
    String? storageKey,
    Object? altText = _Undefined,
    DateTime? createdAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return Attachment(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      kind: kind ?? this.kind,
      filename: filename ?? this.filename,
      contentType: contentType ?? this.contentType,
      bytes: bytes ?? this.bytes,
      storageKey: storageKey ?? this.storageKey,
      altText: altText is String? ? altText : this.altText,
      createdAt: createdAt ?? this.createdAt,
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

class AttachmentUpdateTable extends _i1.UpdateTable<AttachmentTable> {
  AttachmentUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> entityType(String value) => _i1.ColumnValue(
    table.entityType,
    value,
  );

  _i1.ColumnValue<int, int> entityId(int value) => _i1.ColumnValue(
    table.entityId,
    value,
  );

  _i1.ColumnValue<_i2.AttachmentKind, _i2.AttachmentKind> kind(
    _i2.AttachmentKind value,
  ) => _i1.ColumnValue(
    table.kind,
    value,
  );

  _i1.ColumnValue<String, String> filename(String value) => _i1.ColumnValue(
    table.filename,
    value,
  );

  _i1.ColumnValue<String, String> contentType(String value) => _i1.ColumnValue(
    table.contentType,
    value,
  );

  _i1.ColumnValue<int, int> bytes(int value) => _i1.ColumnValue(
    table.bytes,
    value,
  );

  _i1.ColumnValue<String, String> storageKey(String value) => _i1.ColumnValue(
    table.storageKey,
    value,
  );

  _i1.ColumnValue<String, String> altText(String? value) => _i1.ColumnValue(
    table.altText,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
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

class AttachmentTable extends _i1.Table<int?> {
  AttachmentTable({super.tableRelation}) : super(tableName: 'attachment') {
    updateTable = AttachmentUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    entityType = _i1.ColumnString(
      'entityType',
      this,
    );
    entityId = _i1.ColumnInt(
      'entityId',
      this,
    );
    kind = _i1.ColumnEnum(
      'kind',
      this,
      _i1.EnumSerialization.byName,
      hasDefault: true,
    );
    filename = _i1.ColumnString(
      'filename',
      this,
    );
    contentType = _i1.ColumnString(
      'contentType',
      this,
    );
    bytes = _i1.ColumnInt(
      'bytes',
      this,
    );
    storageKey = _i1.ColumnString(
      'storageKey',
      this,
    );
    altText = _i1.ColumnString(
      'altText',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
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

  late final AttachmentUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString entityType;

  late final _i1.ColumnInt entityId;

  late final _i1.ColumnEnum<_i2.AttachmentKind> kind;

  late final _i1.ColumnString filename;

  late final _i1.ColumnString contentType;

  late final _i1.ColumnInt bytes;

  late final _i1.ColumnString storageKey;

  late final _i1.ColumnString altText;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnInt createdByUserInfoId;

  late final _i1.ColumnDateTime deletedAt;

  late final _i1.ColumnInt deletedByUserInfoId;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    entityType,
    entityId,
    kind,
    filename,
    contentType,
    bytes,
    storageKey,
    altText,
    createdAt,
    createdByUserInfoId,
    deletedAt,
    deletedByUserInfoId,
  ];
}

class AttachmentInclude extends _i1.IncludeObject {
  AttachmentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Attachment.t;
}

class AttachmentIncludeList extends _i1.IncludeList {
  AttachmentIncludeList._({
    _i1.WhereExpressionBuilder<AttachmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Attachment.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Attachment.t;
}

class AttachmentRepository {
  const AttachmentRepository._();

  /// Returns a list of [Attachment]s matching the given query parameters.
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
  Future<List<Attachment>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AttachmentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AttachmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AttachmentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Attachment>(
      where: where?.call(Attachment.t),
      orderBy: orderBy?.call(Attachment.t),
      orderByList: orderByList?.call(Attachment.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Attachment] matching the given query parameters.
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
  Future<Attachment?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AttachmentTable>? where,
    int? offset,
    _i1.OrderByBuilder<AttachmentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<AttachmentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Attachment>(
      where: where?.call(Attachment.t),
      orderBy: orderBy?.call(Attachment.t),
      orderByList: orderByList?.call(Attachment.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Attachment] by its [id] or null if no such row exists.
  Future<Attachment?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Attachment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Attachment]s in the list and returns the inserted rows.
  ///
  /// The returned [Attachment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Attachment>> insert(
    _i1.DatabaseSession session,
    List<Attachment> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Attachment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Attachment] and returns the inserted row.
  ///
  /// The returned [Attachment] will have its `id` field set.
  Future<Attachment> insertRow(
    _i1.DatabaseSession session,
    Attachment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Attachment>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Attachment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Attachment>> update(
    _i1.DatabaseSession session,
    List<Attachment> rows, {
    _i1.ColumnSelections<AttachmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Attachment>(
      rows,
      columns: columns?.call(Attachment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Attachment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Attachment> updateRow(
    _i1.DatabaseSession session,
    Attachment row, {
    _i1.ColumnSelections<AttachmentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Attachment>(
      row,
      columns: columns?.call(Attachment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Attachment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Attachment?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<AttachmentUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Attachment>(
      id,
      columnValues: columnValues(Attachment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Attachment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Attachment>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<AttachmentUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<AttachmentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<AttachmentTable>? orderBy,
    _i1.OrderByListBuilder<AttachmentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Attachment>(
      columnValues: columnValues(Attachment.t.updateTable),
      where: where(Attachment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Attachment.t),
      orderByList: orderByList?.call(Attachment.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Attachment]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Attachment>> delete(
    _i1.DatabaseSession session,
    List<Attachment> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Attachment>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Attachment].
  Future<Attachment> deleteRow(
    _i1.DatabaseSession session,
    Attachment row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Attachment>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Attachment>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AttachmentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Attachment>(
      where: where(Attachment.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<AttachmentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Attachment>(
      where: where?.call(Attachment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Attachment] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<AttachmentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Attachment>(
      where: where(Attachment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
