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

/// A compact realtime change notice broadcast on an org channel and streamed
/// to subscribers (Appendix C). Also the unit the offline sync engine applies.
abstract class ChangeEvent implements _i1.SerializableModel {
  ChangeEvent._({
    required this.entityType,
    required this.entityId,
    required this.op,
    required this.version,
    required this.updatedAt,
  });

  factory ChangeEvent({
    required String entityType,
    required int entityId,
    required String op,
    required int version,
    required DateTime updatedAt,
  }) = _ChangeEventImpl;

  factory ChangeEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChangeEvent(
      entityType: jsonSerialization['entityType'] as String,
      entityId: jsonSerialization['entityId'] as int,
      op: jsonSerialization['op'] as String,
      version: jsonSerialization['version'] as int,
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  String entityType;

  int entityId;

  String op;

  int version;

  DateTime updatedAt;

  /// Returns a shallow copy of this [ChangeEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChangeEvent copyWith({
    String? entityType,
    int? entityId,
    String? op,
    int? version,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChangeEvent',
      'entityType': entityType,
      'entityId': entityId,
      'op': op,
      'version': version,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ChangeEventImpl extends ChangeEvent {
  _ChangeEventImpl({
    required String entityType,
    required int entityId,
    required String op,
    required int version,
    required DateTime updatedAt,
  }) : super._(
         entityType: entityType,
         entityId: entityId,
         op: op,
         version: version,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ChangeEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChangeEvent copyWith({
    String? entityType,
    int? entityId,
    String? op,
    int? version,
    DateTime? updatedAt,
  }) {
    return ChangeEvent(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
