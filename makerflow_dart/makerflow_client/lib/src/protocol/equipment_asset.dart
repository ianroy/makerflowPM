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
import 'enums/equipment_status.dart' as _i2;

/// Trackable equipment with maintenance + certification state.
abstract class EquipmentAsset implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
