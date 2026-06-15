import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'auth_context.dart';

/// Central authorization gate. The Dart analog of the legacy `role_allows()`.
///
/// Every mutating endpoint calls [requireRole] first. It:
///   1. confirms the caller is authenticated,
///   2. loads their [Membership] in the target organization,
///   3. confirms their role meets [minRole] (superusers bypass),
/// and returns an [AuthContext] for downstream tenancy + audit.
class RbacGuard {
  /// Integer rank of a role; higher = more privileged. Drives comparisons.
  static int rank(MembershipRole role) => MembershipRole.values.indexOf(role);

  static bool atLeast(MembershipRole have, MembershipRole need) =>
      rank(have) >= rank(need);

  static Future<AuthContext> requireRole(
    Session session,
    int organizationId,
    MembershipRole minRole,
  ) async {
    final userInfoId = await AuthIdentity.requireUserInfoId(session);
    final superuser = await AuthIdentity.isSuperuser(session);

    final membership = await Membership.db.findFirstRow(
      session,
      where: (m) =>
          m.userInfoId.equals(userInfoId) &
          m.organizationId.equals(organizationId),
    );

    if (membership == null) {
      if (superuser) {
        // Superusers may act across orgs even without an explicit membership.
        return AuthContext(
          userInfoId: userInfoId,
          organizationId: organizationId,
          role: MembershipRole.owner,
          isSuperuser: true,
        );
      }
      throw const MakerflowForbiddenException(
        'No membership in the requested organization.',
      );
    }

    if (!superuser && !atLeast(membership.role, minRole)) {
      throw MakerflowForbiddenException(
        'Requires ${minRole.name}; caller is ${membership.role.name}.',
      );
    }

    return AuthContext(
      userInfoId: userInfoId,
      organizationId: organizationId,
      role: membership.role,
      isSuperuser: superuser,
    );
  }
}
