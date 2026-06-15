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

/// Outbound email log (parity with legacy email_messages).
abstract class EmailMessage
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  EmailMessage._({
    this.id,
    this.organizationId,
    required this.toAddress,
    required this.subject,
    String? status,
    this.error,
    this.sentAt,
    required this.createdAt,
  }) : status = status ?? 'queued';

  factory EmailMessage({
    int? id,
    int? organizationId,
    required String toAddress,
    required String subject,
    String? status,
    String? error,
    DateTime? sentAt,
    required DateTime createdAt,
  }) = _EmailMessageImpl;

  factory EmailMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return EmailMessage(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int?,
      toAddress: jsonSerialization['toAddress'] as String,
      subject: jsonSerialization['subject'] as String,
      status: jsonSerialization['status'] as String?,
      error: jsonSerialization['error'] as String?,
      sentAt: jsonSerialization['sentAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['sentAt']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = EmailMessageTable();

  static const db = EmailMessageRepository._();

  @override
  int? id;

  int? organizationId;

  String toAddress;

  String subject;

  String status;

  String? error;

  DateTime? sentAt;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [EmailMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EmailMessage copyWith({
    int? id,
    int? organizationId,
    String? toAddress,
    String? subject,
    String? status,
    String? error,
    DateTime? sentAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EmailMessage',
      if (id != null) 'id': id,
      if (organizationId != null) 'organizationId': organizationId,
      'toAddress': toAddress,
      'subject': subject,
      'status': status,
      if (error != null) 'error': error,
      if (sentAt != null) 'sentAt': sentAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EmailMessage',
      if (id != null) 'id': id,
      if (organizationId != null) 'organizationId': organizationId,
      'toAddress': toAddress,
      'subject': subject,
      'status': status,
      if (error != null) 'error': error,
      if (sentAt != null) 'sentAt': sentAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static EmailMessageInclude include() {
    return EmailMessageInclude._();
  }

  static EmailMessageIncludeList includeList({
    _i1.WhereExpressionBuilder<EmailMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailMessageTable>? orderByList,
    EmailMessageInclude? include,
  }) {
    return EmailMessageIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmailMessage.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(EmailMessage.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EmailMessageImpl extends EmailMessage {
  _EmailMessageImpl({
    int? id,
    int? organizationId,
    required String toAddress,
    required String subject,
    String? status,
    String? error,
    DateTime? sentAt,
    required DateTime createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         toAddress: toAddress,
         subject: subject,
         status: status,
         error: error,
         sentAt: sentAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [EmailMessage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EmailMessage copyWith({
    Object? id = _Undefined,
    Object? organizationId = _Undefined,
    String? toAddress,
    String? subject,
    String? status,
    Object? error = _Undefined,
    Object? sentAt = _Undefined,
    DateTime? createdAt,
  }) {
    return EmailMessage(
      id: id is int? ? id : this.id,
      organizationId: organizationId is int?
          ? organizationId
          : this.organizationId,
      toAddress: toAddress ?? this.toAddress,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      error: error is String? ? error : this.error,
      sentAt: sentAt is DateTime? ? sentAt : this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class EmailMessageUpdateTable extends _i1.UpdateTable<EmailMessageTable> {
  EmailMessageUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int? value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> toAddress(String value) => _i1.ColumnValue(
    table.toAddress,
    value,
  );

  _i1.ColumnValue<String, String> subject(String value) => _i1.ColumnValue(
    table.subject,
    value,
  );

  _i1.ColumnValue<String, String> status(String value) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<String, String> error(String? value) => _i1.ColumnValue(
    table.error,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> sentAt(DateTime? value) =>
      _i1.ColumnValue(
        table.sentAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class EmailMessageTable extends _i1.Table<int?> {
  EmailMessageTable({super.tableRelation}) : super(tableName: 'email_message') {
    updateTable = EmailMessageUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    toAddress = _i1.ColumnString(
      'toAddress',
      this,
    );
    subject = _i1.ColumnString(
      'subject',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
      hasDefault: true,
    );
    error = _i1.ColumnString(
      'error',
      this,
    );
    sentAt = _i1.ColumnDateTime(
      'sentAt',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final EmailMessageUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString toAddress;

  late final _i1.ColumnString subject;

  late final _i1.ColumnString status;

  late final _i1.ColumnString error;

  late final _i1.ColumnDateTime sentAt;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    toAddress,
    subject,
    status,
    error,
    sentAt,
    createdAt,
  ];
}

class EmailMessageInclude extends _i1.IncludeObject {
  EmailMessageInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => EmailMessage.t;
}

class EmailMessageIncludeList extends _i1.IncludeList {
  EmailMessageIncludeList._({
    _i1.WhereExpressionBuilder<EmailMessageTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EmailMessage.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => EmailMessage.t;
}

class EmailMessageRepository {
  const EmailMessageRepository._();

  /// Returns a list of [EmailMessage]s matching the given query parameters.
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
  Future<List<EmailMessage>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EmailMessageTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailMessageTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EmailMessage>(
      where: where?.call(EmailMessage.t),
      orderBy: orderBy?.call(EmailMessage.t),
      orderByList: orderByList?.call(EmailMessage.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EmailMessage] matching the given query parameters.
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
  Future<EmailMessage?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EmailMessageTable>? where,
    int? offset,
    _i1.OrderByBuilder<EmailMessageTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EmailMessageTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EmailMessage>(
      where: where?.call(EmailMessage.t),
      orderBy: orderBy?.call(EmailMessage.t),
      orderByList: orderByList?.call(EmailMessage.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EmailMessage] by its [id] or null if no such row exists.
  Future<EmailMessage?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EmailMessage>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EmailMessage]s in the list and returns the inserted rows.
  ///
  /// The returned [EmailMessage]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<EmailMessage>> insert(
    _i1.DatabaseSession session,
    List<EmailMessage> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<EmailMessage>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [EmailMessage] and returns the inserted row.
  ///
  /// The returned [EmailMessage] will have its `id` field set.
  Future<EmailMessage> insertRow(
    _i1.DatabaseSession session,
    EmailMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EmailMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EmailMessage]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EmailMessage>> update(
    _i1.DatabaseSession session,
    List<EmailMessage> rows, {
    _i1.ColumnSelections<EmailMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EmailMessage>(
      rows,
      columns: columns?.call(EmailMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EmailMessage]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EmailMessage> updateRow(
    _i1.DatabaseSession session,
    EmailMessage row, {
    _i1.ColumnSelections<EmailMessageTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<EmailMessage>(
      row,
      columns: columns?.call(EmailMessage.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EmailMessage] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EmailMessage?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<EmailMessageUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<EmailMessage>(
      id,
      columnValues: columnValues(EmailMessage.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EmailMessage]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<EmailMessage>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<EmailMessageUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<EmailMessageTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EmailMessageTable>? orderBy,
    _i1.OrderByListBuilder<EmailMessageTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<EmailMessage>(
      columnValues: columnValues(EmailMessage.t.updateTable),
      where: where(EmailMessage.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EmailMessage.t),
      orderByList: orderByList?.call(EmailMessage.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EmailMessage]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EmailMessage>> delete(
    _i1.DatabaseSession session,
    List<EmailMessage> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EmailMessage>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EmailMessage].
  Future<EmailMessage> deleteRow(
    _i1.DatabaseSession session,
    EmailMessage row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EmailMessage>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EmailMessage>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EmailMessageTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EmailMessage>(
      where: where(EmailMessage.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EmailMessageTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EmailMessage>(
      where: where?.call(EmailMessage.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EmailMessage] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EmailMessageTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EmailMessage>(
      where: where(EmailMessage.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
