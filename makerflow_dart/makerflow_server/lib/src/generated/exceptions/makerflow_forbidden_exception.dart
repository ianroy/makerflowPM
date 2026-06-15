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

/// Thrown when an authenticated caller lacks the required role or crosses orgs.
abstract class MakerflowForbiddenException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MakerflowForbiddenException._({
    required this.message,
    this.requiredRole,
  });

  factory MakerflowForbiddenException({
    required String message,
    String? requiredRole,
  }) = _MakerflowForbiddenExceptionImpl;

  factory MakerflowForbiddenException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return MakerflowForbiddenException(
      message: jsonSerialization['message'] as String,
      requiredRole: jsonSerialization['requiredRole'] as String?,
    );
  }

  String message;

  String? requiredRole;

  /// Returns a shallow copy of this [MakerflowForbiddenException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MakerflowForbiddenException copyWith({
    String? message,
    String? requiredRole,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MakerflowForbiddenException',
      'message': message,
      if (requiredRole != null) 'requiredRole': requiredRole,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MakerflowForbiddenException',
      'message': message,
      if (requiredRole != null) 'requiredRole': requiredRole,
    };
  }

  @override
  String toString() {
    return 'MakerflowForbiddenException(message: $message, requiredRole: $requiredRole)';
  }
}

class _Undefined {}

class _MakerflowForbiddenExceptionImpl extends MakerflowForbiddenException {
  _MakerflowForbiddenExceptionImpl({
    required String message,
    String? requiredRole,
  }) : super._(
         message: message,
         requiredRole: requiredRole,
       );

  /// Returns a shallow copy of this [MakerflowForbiddenException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MakerflowForbiddenException copyWith({
    String? message,
    Object? requiredRole = _Undefined,
  }) {
    return MakerflowForbiddenException(
      message: message ?? this.message,
      requiredRole: requiredRole is String? ? requiredRole : this.requiredRole,
    );
  }
}
