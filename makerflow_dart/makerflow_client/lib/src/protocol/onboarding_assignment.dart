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
import 'enums/onboarding_state.dart' as _i2;

/// A template assigned to a person, with progress + completion.
abstract class OnboardingAssignment implements _i1.SerializableModel {
  OnboardingAssignment._({
    this.id,
    required this.organizationId,
    required this.templateId,
    required this.assigneeUserInfoId,
    _i2.OnboardingState? state,
    this.progressJson,
    this.dueAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  }) : state = state ?? _i2.OnboardingState.notStarted;

  factory OnboardingAssignment({
    int? id,
    required int organizationId,
    required int templateId,
    required int assigneeUserInfoId,
    _i2.OnboardingState? state,
    String? progressJson,
    DateTime? dueAt,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OnboardingAssignmentImpl;

  factory OnboardingAssignment.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return OnboardingAssignment(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      templateId: jsonSerialization['templateId'] as int,
      assigneeUserInfoId: jsonSerialization['assigneeUserInfoId'] as int,
      state: jsonSerialization['state'] == null
          ? null
          : _i2.OnboardingState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      progressJson: jsonSerialization['progressJson'] as String?,
      dueAt: jsonSerialization['dueAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  int templateId;

  int assigneeUserInfoId;

  _i2.OnboardingState state;

  String? progressJson;

  DateTime? dueAt;

  DateTime? completedAt;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [OnboardingAssignment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OnboardingAssignment copyWith({
    int? id,
    int? organizationId,
    int? templateId,
    int? assigneeUserInfoId,
    _i2.OnboardingState? state,
    String? progressJson,
    DateTime? dueAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OnboardingAssignment',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'templateId': templateId,
      'assigneeUserInfoId': assigneeUserInfoId,
      'state': state.toJson(),
      if (progressJson != null) 'progressJson': progressJson,
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OnboardingAssignmentImpl extends OnboardingAssignment {
  _OnboardingAssignmentImpl({
    int? id,
    required int organizationId,
    required int templateId,
    required int assigneeUserInfoId,
    _i2.OnboardingState? state,
    String? progressJson,
    DateTime? dueAt,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         templateId: templateId,
         assigneeUserInfoId: assigneeUserInfoId,
         state: state,
         progressJson: progressJson,
         dueAt: dueAt,
         completedAt: completedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [OnboardingAssignment]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OnboardingAssignment copyWith({
    Object? id = _Undefined,
    int? organizationId,
    int? templateId,
    int? assigneeUserInfoId,
    _i2.OnboardingState? state,
    Object? progressJson = _Undefined,
    Object? dueAt = _Undefined,
    Object? completedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OnboardingAssignment(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      templateId: templateId ?? this.templateId,
      assigneeUserInfoId: assigneeUserInfoId ?? this.assigneeUserInfoId,
      state: state ?? this.state,
      progressJson: progressJson is String? ? progressJson : this.progressJson,
      dueAt: dueAt is DateTime? ? dueAt : this.dueAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
