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

/// Agenda line item. Supports parent/child nesting and can link to a task or
/// project (the meeting → execution bridge) or be converted into one.
abstract class MeetingItem implements _i1.SerializableModel {
  MeetingItem._({
    this.id,
    required this.organizationId,
    required this.agendaId,
    this.parentItemId,
    required this.title,
    this.notes,
    String? status,
    this.linkedTaskId,
    this.linkedProjectId,
    double? sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : status = status ?? 'open',
       sortOrder = sortOrder ?? 0.0;

  factory MeetingItem({
    int? id,
    required int organizationId,
    required int agendaId,
    int? parentItemId,
    required String title,
    String? notes,
    String? status,
    int? linkedTaskId,
    int? linkedProjectId,
    double? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _MeetingItemImpl;

  factory MeetingItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return MeetingItem(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      agendaId: jsonSerialization['agendaId'] as int,
      parentItemId: jsonSerialization['parentItemId'] as int?,
      title: jsonSerialization['title'] as String,
      notes: jsonSerialization['notes'] as String?,
      status: jsonSerialization['status'] as String?,
      linkedTaskId: jsonSerialization['linkedTaskId'] as int?,
      linkedProjectId: jsonSerialization['linkedProjectId'] as int?,
      sortOrder: (jsonSerialization['sortOrder'] as num?)?.toDouble(),
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  int agendaId;

  int? parentItemId;

  String title;

  String? notes;

  String status;

  int? linkedTaskId;

  int? linkedProjectId;

  double sortOrder;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [MeetingItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MeetingItem copyWith({
    int? id,
    int? organizationId,
    int? agendaId,
    int? parentItemId,
    String? title,
    String? notes,
    String? status,
    int? linkedTaskId,
    int? linkedProjectId,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MeetingItem',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'agendaId': agendaId,
      if (parentItemId != null) 'parentItemId': parentItemId,
      'title': title,
      if (notes != null) 'notes': notes,
      'status': status,
      if (linkedTaskId != null) 'linkedTaskId': linkedTaskId,
      if (linkedProjectId != null) 'linkedProjectId': linkedProjectId,
      'sortOrder': sortOrder,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MeetingItemImpl extends MeetingItem {
  _MeetingItemImpl({
    int? id,
    required int organizationId,
    required int agendaId,
    int? parentItemId,
    required String title,
    String? notes,
    String? status,
    int? linkedTaskId,
    int? linkedProjectId,
    double? sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         agendaId: agendaId,
         parentItemId: parentItemId,
         title: title,
         notes: notes,
         status: status,
         linkedTaskId: linkedTaskId,
         linkedProjectId: linkedProjectId,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [MeetingItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MeetingItem copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? agendaId,
    Object? parentItemId = _Undefined,
    String? title,
    Object? notes = _Undefined,
    String? status,
    Object? linkedTaskId = _Undefined,
    Object? linkedProjectId = _Undefined,
    double? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return MeetingItem(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      agendaId: agendaId ?? this.agendaId,
      parentItemId: parentItemId is int? ? parentItemId : this.parentItemId,
      title: title ?? this.title,
      notes: notes is String? ? notes : this.notes,
      status: status ?? this.status,
      linkedTaskId: linkedTaskId is int? ? linkedTaskId : this.linkedTaskId,
      linkedProjectId: linkedProjectId is int?
          ? linkedProjectId
          : this.linkedProjectId,
      sortOrder: sortOrder ?? this.sortOrder,
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
