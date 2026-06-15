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

/// Point-in-time aggregate seeded by the reports module.
abstract class InsightSnapshot implements _i1.SerializableModel {
  InsightSnapshot._({
    this.id,
    required this.organizationId,
    required this.metricKey,
    required this.value,
    required this.capturedAt,
    this.dimensionsJson,
  });

  factory InsightSnapshot({
    int? id,
    required int organizationId,
    required String metricKey,
    required double value,
    required DateTime capturedAt,
    String? dimensionsJson,
  }) = _InsightSnapshotImpl;

  factory InsightSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return InsightSnapshot(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      metricKey: jsonSerialization['metricKey'] as String,
      value: (jsonSerialization['value'] as num).toDouble(),
      capturedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['capturedAt'],
      ),
      dimensionsJson: jsonSerialization['dimensionsJson'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  String metricKey;

  double value;

  DateTime capturedAt;

  String? dimensionsJson;

  /// Returns a shallow copy of this [InsightSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  InsightSnapshot copyWith({
    int? id,
    int? organizationId,
    String? metricKey,
    double? value,
    DateTime? capturedAt,
    String? dimensionsJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InsightSnapshot',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'metricKey': metricKey,
      'value': value,
      'capturedAt': capturedAt.toJson(),
      if (dimensionsJson != null) 'dimensionsJson': dimensionsJson,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InsightSnapshotImpl extends InsightSnapshot {
  _InsightSnapshotImpl({
    int? id,
    required int organizationId,
    required String metricKey,
    required double value,
    required DateTime capturedAt,
    String? dimensionsJson,
  }) : super._(
         id: id,
         organizationId: organizationId,
         metricKey: metricKey,
         value: value,
         capturedAt: capturedAt,
         dimensionsJson: dimensionsJson,
       );

  /// Returns a shallow copy of this [InsightSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  InsightSnapshot copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? metricKey,
    double? value,
    DateTime? capturedAt,
    Object? dimensionsJson = _Undefined,
  }) {
    return InsightSnapshot(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      metricKey: metricKey ?? this.metricKey,
      value: value ?? this.value,
      capturedAt: capturedAt ?? this.capturedAt,
      dimensionsJson: dimensionsJson is String?
          ? dimensionsJson
          : this.dimensionsJson,
    );
  }
}
