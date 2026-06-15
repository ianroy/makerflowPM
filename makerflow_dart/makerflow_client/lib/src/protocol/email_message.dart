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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// Outbound email log (parity with legacy email_messages).
abstract class EmailMessage implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int? organizationId;

  String toAddress;

  String subject;

  String status;

  String? error;

  DateTime? sentAt;

  DateTime createdAt;

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
