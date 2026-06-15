import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import '../generated/protocol.dart';

/// Resolved identity + role for the active organization on a single request.
///
/// This is the Dart analog of the legacy Python `get_auth_context()`. It is
/// produced by [RbacGuard.requireRole] and threaded into business logic so no
/// endpoint re-derives authorization ad hoc.
class AuthContext {
  AuthContext({
    required this.userInfoId,
    required this.organizationId,
    required this.role,
    required this.isSuperuser,
  });

  final int userInfoId;
  final int organizationId;
  final MembershipRole role;

  /// Platform-level superuser (the only path to cross-workspace administration).
  final bool isSuperuser;
}

/// Helpers for reading the authenticated serverpod_auth user off a [Session].
class AuthIdentity {
  /// Returns the signed-in UserInfo id, or throws if unauthenticated.
  static Future<int> requireUserInfoId(Session session) async {
    final authInfo = session.authenticated;
    final userId = authInfo?.userId;
    if (userId == null) {
      throw MakerflowAuthException(message: 'Authentication required.');
    }
    return userId;
  }

  /// Whether the signed-in user carries the platform `superuser` scope.
  static Future<bool> isSuperuser(Session session) async {
    final authInfo = session.authenticated;
    return authInfo?.scopes.contains(const Scope('superuser')) ?? false;
  }

  /// Convenience: load the serverpod_auth UserInfo (name/email) for a user id.
  static Future<auth.UserInfo?> userInfo(Session session, int userInfoId) {
    return auth.Users.findUserByUserId(session, userInfoId);
  }
}

// MakerflowAuthException + MakerflowForbiddenException are now Serverpod
// serializable exceptions, generated from lib/src/models/exceptions/ and
// available via generated/protocol.dart (so they cross the wire as typed
// errors). The hand-written classes were removed in fl-0-error-taxonomy.
