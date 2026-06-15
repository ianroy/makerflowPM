import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/auth_context.dart';
import '../business/rbac.dart';

/// Organizations + memberships. Replaces the legacy org switch (`?org=`) and
/// `/admin/users*` routes. Enforces the workspace_admin/owner boundary from
/// docs/SECURITY.md: workspace admins manage their own org but cannot grant or
/// modify `owner` unless they are owner/superuser.
class OrgEndpoint extends Endpoint {
  /// Organizations the caller belongs to (for the org switcher).
  Future<List<Organization>> listMine(Session session) async {
    final userInfoId = await AuthIdentity.requireUserInfoId(session);
    final memberships = await Membership.db.find(
      session,
      where: (m) => m.userInfoId.equals(userInfoId),
    );
    final orgIds = memberships.map((m) => m.organizationId).toSet().toList();
    if (orgIds.isEmpty) return [];
    return Organization.db.find(session, where: (o) => o.id.inSet(orgIds.toSet()));
  }

  /// Members of an org (manager+).
  Future<List<Membership>> members(Session session, int organizationId) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.manager);
    return Membership.db.find(session,
        where: (m) => m.organizationId.equals(organizationId));
  }

  /// Add or update a member's role (workspace_admin+). Cannot set/modify `owner`
  /// unless the caller is owner or superuser.
  Future<Membership> setRole(
    Session session,
    int organizationId,
    int targetUserInfoId,
    MembershipRole role,
  ) async {
    final ctx = await RbacGuard.requireRole(
        session, organizationId, MembershipRole.workspaceAdmin);

    final grantingOwner = role == MembershipRole.owner;
    final actingOwner = ctx.role == MembershipRole.owner || ctx.isSuperuser;
    if (grantingOwner && !actingOwner) {
      throw MakerflowForbiddenException(message: 'Only an owner or superuser may grant the owner role.',
      );
    }

    final existing = await Membership.db.findFirstRow(
      session,
      where: (m) =>
          m.organizationId.equals(organizationId) &
          m.userInfoId.equals(targetUserInfoId),
    );

    // Protect existing owners from downgrade by non-owners.
    if (existing != null &&
        existing.role == MembershipRole.owner &&
        !actingOwner) {
      throw MakerflowForbiddenException(message: 'Only an owner or superuser may modify an owner account.',
      );
    }

    final now = DateTime.now().toUtc();
    final saved = existing == null
        ? await Membership.db.insertRow(
            session,
            Membership(
              organizationId: organizationId,
              userInfoId: targetUserInfoId,
              role: role,
              createdAt: now,
              updatedAt: now,
            ),
          )
        : await Membership.db
            .updateRow(session, existing.copyWith(role: role, updatedAt: now));

    await Audit.record(session,
        ctx: ctx,
        entityType: 'membership',
        entityId: saved.id,
        action: existing == null ? 'create' : 'update',
        summary: 'role=${role.name} user=$targetUserInfoId');
    return saved;
  }

  /// Remove a member (workspace_admin+; owners protected as above).
  Future<void> removeMember(
      Session session, int organizationId, int targetUserInfoId) async {
    final ctx = await RbacGuard.requireRole(
        session, organizationId, MembershipRole.workspaceAdmin);
    final existing = await Membership.db.findFirstRow(
      session,
      where: (m) =>
          m.organizationId.equals(organizationId) &
          m.userInfoId.equals(targetUserInfoId),
    );
    if (existing == null) return;
    if (existing.role == MembershipRole.owner &&
        !(ctx.role == MembershipRole.owner || ctx.isSuperuser)) {
      throw MakerflowForbiddenException(message: 'Only an owner or superuser may remove an owner.');
    }
    await Membership.db.deleteRow(session, existing);
    await Audit.record(session,
        ctx: ctx,
        entityType: 'membership',
        entityId: existing.id,
        action: 'delete',
        summary: 'user=$targetUserInfoId');
  }
}
