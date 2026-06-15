import 'auth_context.dart';

/// Tenancy invariants. The Dart analog of the legacy explicit
/// `WHERE organization_id = ?` discipline.
///
/// Endpoints already pass `organizationId` into `RbacGuard.requireRole`, which
/// proves the caller belongs to that org. These guards add belt-and-suspenders
/// checks for the two ways tenancy is most often violated:
///   • reading/writing a row whose org differs from the caller's context,
///   • reassigning a row's org on update.
class Tenancy {
  /// Throws if [rowOrganizationId] is not the caller's active org.
  static void assertSameOrg(AuthContext ctx, int rowOrganizationId) {
    if (rowOrganizationId != ctx.organizationId && !ctx.isSuperuser) {
      throw const MakerflowForbiddenException(
        'Cross-organization access is not permitted.',
      );
    }
  }

  /// Throws if an update attempts to move a row to a different org.
  static void assertNoOrgReassignment(int existingOrgId, int incomingOrgId) {
    if (existingOrgId != incomingOrgId) {
      throw const MakerflowForbiddenException(
        'organizationId is immutable on update.',
      );
    }
  }
}
