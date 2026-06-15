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
import 'enums/consumable_status.dart' as _i2;

/// Per-space stock + reorder tracking.
abstract class Consumable implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
