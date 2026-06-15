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
import 'enums/partnership_stage.dart' as _i2;

/// External/internal relationship pipeline.
abstract class Partnership implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
