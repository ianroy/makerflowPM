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
import 'task.dart' as _i2;
import 'package:makerflow_server/src/generated/protocol.dart' as _i3;

/// Wire type for SyncEndpoint.pullTasks. Serverpod needs concrete serializable
/// page types (no generics over the wire), so each synced entity gets one.
/// `tasks` includes soft-deleted rows as tombstones (deletedAt != null).
abstract class TaskDeltaPage
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  TaskDeltaPage._({
    required this.tasks,
    this.nextCursor,
  });

  factory TaskDeltaPage({
    required List<_i2.Task> tasks,
    String? nextCursor,
  }) = _TaskDeltaPageImpl;

  factory TaskDeltaPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaskDeltaPage(
      tasks: _i3.Protocol().deserialize<List<_i2.Task>>(
        jsonSerialization['tasks'],
      ),
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  List<_i2.Task> tasks;

  String? nextCursor;

  /// Returns a shallow copy of this [TaskDeltaPage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  TaskDeltaPage copyWith({
    List<_i2.Task>? tasks,
    String? nextCursor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaskDeltaPage',
      'tasks': tasks.toJson(valueToJson: (v) => v.toJson()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaskDeltaPage',
      'tasks': tasks.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskDeltaPageImpl extends TaskDeltaPage {
  _TaskDeltaPageImpl({
    required List<_i2.Task> tasks,
    String? nextCursor,
  }) : super._(
         tasks: tasks,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [TaskDeltaPage]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  TaskDeltaPage copyWith({
    List<_i2.Task>? tasks,
    Object? nextCursor = _Undefined,
  }) {
    return TaskDeltaPage(
      tasks: tasks ?? this.tasks.map((e0) => e0.copyWith()).toList(),
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}
