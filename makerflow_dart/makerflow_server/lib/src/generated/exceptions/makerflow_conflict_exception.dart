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

/// Thrown on a stale optimistic-version write (offline reconcile, R5/R9).
abstract class MakerflowConflictException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MakerflowConflictException._({
    required this.message,
    this.currentVersion,
  });

  factory MakerflowConflictException({
    required String message,
    int? currentVersion,
  }) = _MakerflowConflictExceptionImpl;

  factory MakerflowConflictException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MakerflowConflictException(
      message: jsonSerialization['message'] as String,
      currentVersion: jsonSerialization['currentVersion'] as int?,
    );
  }

  String message;

  int? currentVersion;

  /// Returns a shallow copy of this [MakerflowConflictException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MakerflowConflictException copyWith({
    String? message,
    int? currentVersion,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MakerflowConflictException',
      'message': message,
      if (currentVersion != null) 'currentVersion': currentVersion,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MakerflowConflictException',
      'message': message,
      if (currentVersion != null) 'currentVersion': currentVersion,
    };
  }

  @override
  String toString() {
    return 'MakerflowConflictException(message: $message, currentVersion: $currentVersion)';
  }
}

class _Undefined {}

class _MakerflowConflictExceptionImpl extends MakerflowConflictException {
  _MakerflowConflictExceptionImpl({
    required String message,
    int? currentVersion,
  }) : super._(
         message: message,
         currentVersion: currentVersion,
       );

  /// Returns a shallow copy of this [MakerflowConflictException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MakerflowConflictException copyWith({
    String? message,
    Object? currentVersion = _Undefined,
  }) {
    return MakerflowConflictException(
      message: message ?? this.message,
      currentVersion: currentVersion is int?
          ? currentVersion
          : this.currentVersion,
    );
  }
}
