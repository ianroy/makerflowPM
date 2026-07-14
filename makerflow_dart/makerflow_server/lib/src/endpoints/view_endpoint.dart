import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/auth_context.dart';
import '../business/rbac.dart';

/// Saved views (fl-8-view-field-endpoints). A view is personal by default;
/// `isShared` publishes it org-wide (read-only for non-owners). Any member
/// manages their OWN views; editing someone else's requires workspaceAdmin+.
/// Same contract as TaskEndpoint: requireRole → org-scope → version → audit →
/// soft-delete.
class ViewEndpoint extends Endpoint {
  /// The caller's views + shared org views, optionally per entity type.
  Future<List<CustomView>> list(Session session, int organizationId,
      {String? entityType}) async {
    final ctx =
        await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return CustomView.db.find(
      session,
      where: (v) {
        var w = v.organizationId.equals(organizationId) &
            v.deletedAt.equals(null) &
            (v.ownerUserInfoId.equals(ctx.userInfoId) | v.isShared.equals(true));
        if (entityType != null) w &= v.entityType.equals(entityType);
        return w;
      },
      orderBy: (v) => v.name,
    );
  }

  /// Create or update a view. Owner (or workspaceAdmin+) only for updates;
  /// optimistic version check; tenancy + ownership pinned server-side.
  Future<CustomView> save(Session session, CustomView draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.viewer);
    final now = DateTime.now().toUtc();

    final draftId = draft.id;
    final CustomView saved;
    if (draftId == null) {
      saved = await CustomView.db.insertRow(
        session,
        draft.copyWith(
          ownerUserInfoId: ctx.userInfoId, // ownership cannot be assigned away
          version: 1,
          createdAt: now,
          updatedAt: now,
          deletedAt: null,
          deletedByUserInfoId: null,
        ),
      );
    } else {
      final existing = await _requireLive(session, draftId);
      await _requireOwnerOrAdmin(session, existing);
      if (draft.version != existing.version) {
        throw MakerflowConflictException(
            message: 'View was modified by someone else. Reload and retry.');
      }
      saved = await CustomView.db.updateRow(
        session,
        draft.copyWith(
          organizationId: existing.organizationId, // tenancy pinned
          ownerUserInfoId: existing.ownerUserInfoId, // ownership pinned
          version: existing.version + 1,
          createdAt: existing.createdAt,
          updatedAt: now,
          deletedAt: null,
          deletedByUserInfoId: null,
        ),
      );
    }
    await Audit.record(session,
        ctx: ctx,
        entityType: 'customView',
        entityId: saved.id,
        action: draftId == null ? 'create' : 'update',
        summary: 'name=${saved.name} shared=${saved.isShared}');
    return saved;
  }

  /// Soft-delete a view (owner or workspaceAdmin+).
  Future<void> softDelete(Session session, int id) async {
    final existing = await _requireLive(session, id);
    final ctx = await _requireOwnerOrAdmin(session, existing);
    await CustomView.db.updateRow(
      session,
      existing.copyWith(
        deletedAt: DateTime.now().toUtc(),
        deletedByUserInfoId: ctx.userInfoId,
      ),
    );
    await Audit.record(session,
        ctx: ctx, entityType: 'customView', entityId: id, action: 'delete');
  }

  Future<CustomView> _requireLive(Session session, int id) async {
    final v = await CustomView.db.findById(session, id);
    if (v == null || v.deletedAt != null) {
      throw MakerflowNotFoundException(message: 'View not found.');
    }
    return v;
  }

  /// Membership check in the view's org, then owner-or-admin authorization.
  Future<AuthContext> _requireOwnerOrAdmin(
      Session session, CustomView view) async {
    final ctx = await RbacGuard.requireRole(
        session, view.organizationId, MembershipRole.viewer);
    final isOwner = view.ownerUserInfoId == ctx.userInfoId;
    final isAdmin =
        RbacGuard.atLeast(ctx.role, MembershipRole.workspaceAdmin) ||
            ctx.isSuperuser;
    if (!isOwner && !isAdmin) {
      throw MakerflowForbiddenException(
          message: 'Only the view owner or a workspace admin may modify it.');
    }
    return ctx;
  }
}
