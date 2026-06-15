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
import 'enums/intake_stage.dart' as _i2;

/// Scored intake queue (feature-flagged; matches legacy FEATURE_INTAKE_ENABLED).
abstract class IntakeRequest implements _i1.SerializableModel {
  IntakeRequest._({
    this.id,
    required this.organizationId,
    required this.title,
    this.description,
    _i2.IntakeStage? stage,
    this.score,
    this.requesterName,
    this.requesterEmail,
    this.convertedProjectId,
    required this.createdAt,
    required this.updatedAt,
    this.createdByUserInfoId,
    this.deletedAt,
    this.deletedByUserInfoId,
  }) : stage = stage ?? _i2.IntakeStage.submitted;

  factory IntakeRequest({
    int? id,
    required int organizationId,
    required String title,
    String? description,
    _i2.IntakeStage? stage,
    double? score,
    String? requesterName,
    String? requesterEmail,
    int? convertedProjectId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) = _IntakeRequestImpl;

  factory IntakeRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return IntakeRequest(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      stage: jsonSerialization['stage'] == null
          ? null
          : _i2.IntakeStage.fromJson((jsonSerialization['stage'] as String)),
      score: (jsonSerialization['score'] as num?)?.toDouble(),
      requesterName: jsonSerialization['requesterName'] as String?,
      requesterEmail: jsonSerialization['requesterEmail'] as String?,
      convertedProjectId: jsonSerialization['convertedProjectId'] as int?,
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

  String title;

  String? description;

  _i2.IntakeStage stage;

  double? score;

  String? requesterName;

  String? requesterEmail;

  int? convertedProjectId;

  DateTime createdAt;

  DateTime updatedAt;

  int? createdByUserInfoId;

  DateTime? deletedAt;

  int? deletedByUserInfoId;

  /// Returns a shallow copy of this [IntakeRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IntakeRequest copyWith({
    int? id,
    int? organizationId,
    String? title,
    String? description,
    _i2.IntakeStage? stage,
    double? score,
    String? requesterName,
    String? requesterEmail,
    int? convertedProjectId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IntakeRequest',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'title': title,
      if (description != null) 'description': description,
      'stage': stage.toJson(),
      if (score != null) 'score': score,
      if (requesterName != null) 'requesterName': requesterName,
      if (requesterEmail != null) 'requesterEmail': requesterEmail,
      if (convertedProjectId != null) 'convertedProjectId': convertedProjectId,
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

class _IntakeRequestImpl extends IntakeRequest {
  _IntakeRequestImpl({
    int? id,
    required int organizationId,
    required String title,
    String? description,
    _i2.IntakeStage? stage,
    double? score,
    String? requesterName,
    String? requesterEmail,
    int? convertedProjectId,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? createdByUserInfoId,
    DateTime? deletedAt,
    int? deletedByUserInfoId,
  }) : super._(
         id: id,
         organizationId: organizationId,
         title: title,
         description: description,
         stage: stage,
         score: score,
         requesterName: requesterName,
         requesterEmail: requesterEmail,
         convertedProjectId: convertedProjectId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserInfoId: createdByUserInfoId,
         deletedAt: deletedAt,
         deletedByUserInfoId: deletedByUserInfoId,
       );

  /// Returns a shallow copy of this [IntakeRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IntakeRequest copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? title,
    Object? description = _Undefined,
    _i2.IntakeStage? stage,
    Object? score = _Undefined,
    Object? requesterName = _Undefined,
    Object? requesterEmail = _Undefined,
    Object? convertedProjectId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? createdByUserInfoId = _Undefined,
    Object? deletedAt = _Undefined,
    Object? deletedByUserInfoId = _Undefined,
  }) {
    return IntakeRequest(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      stage: stage ?? this.stage,
      score: score is double? ? score : this.score,
      requesterName: requesterName is String?
          ? requesterName
          : this.requesterName,
      requesterEmail: requesterEmail is String?
          ? requesterEmail
          : this.requesterEmail,
      convertedProjectId: convertedProjectId is int?
          ? convertedProjectId
          : this.convertedProjectId,
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
