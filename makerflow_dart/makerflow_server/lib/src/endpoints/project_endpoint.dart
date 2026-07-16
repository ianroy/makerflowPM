import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';

/// Project CRUD. Same security contract as [TaskEndpoint].
/// Replaces the legacy /projects, /projects/new, /projects/update routes.
class ProjectEndpoint extends Endpoint {
  Future<List<Project>> list(Session session, int organizationId) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return Project.db.find(
      session,
      where: (p) =>
          p.organizationId.equals(organizationId) & p.deletedAt.equals(null),
      orderBy: (p) => p.name,
    );
  }

  Future<Project> create(Session session, Project draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.staff);
    final now = DateTime.now().toUtc();
    final saved = await Project.db.insertRow(
      session,
      draft.copyWith(
        createdAt: now,
        updatedAt: now,
        createdByUserInfoId: ctx.userInfoId,
        deletedAt: null,
        deletedByUserInfoId: null,
      ),
    );
    await Audit.record(session,
        ctx: ctx,
        entityType: 'project',
        entityId: saved.id,
        action: 'create',
        payload: {'name': saved.name});
    return saved;
  }

  /// Update a project. Optimistic-concurrency aware via [Project.version]:
  /// throws if the client's base version is stale (mirrors TaskEndpoint.update).
  Future<Project> update(Session session, Project incoming) async {
    final incomingId = incoming.id;
    if (incomingId == null) {
      throw MakerflowNotFoundException(message: 'Project id is required for update.');
    }
    final existing = await _requireLive(session, incomingId);
    final ctx = await RbacGuard.requireRole(
        session, existing.organizationId, MembershipRole.staff);

    if (incoming.version != existing.version) {
      throw MakerflowConflictException(message: 'Project was modified by someone else. Reload and retry.',
      );
    }

    final updated = incoming.copyWith(
      organizationId: existing.organizationId, // tenancy cannot be reassigned
      version: existing.version + 1,
      createdAt: existing.createdAt,
      createdByUserInfoId: existing.createdByUserInfoId,
      updatedAt: DateTime.now().toUtc(),
      deletedAt: null,
      deletedByUserInfoId: null,
    );
    final saved = await Project.db.updateRow(session, updated);
    await Audit.record(session,
        ctx: ctx,
        entityType: 'project',
        entityId: saved.id,
        action: 'update',
        payload: {'name': saved.name, 'status': saved.status, 'version': saved.version});
    return saved;
  }

  /// Soft-delete (archives the project; tasks keep their projectId and stay
  /// visible — matching the legacy behavior. Restore is server-side until the
  /// trash UI covers projects).
  Future<void> softDelete(Session session, int projectId) async {
    final existing = await _requireLive(session, projectId);
    final ctx = await RbacGuard.requireRole(
        session, existing.organizationId, MembershipRole.staff);
    await Project.db.updateRow(
      session,
      existing.copyWith(
        deletedAt: DateTime.now().toUtc(),
        deletedByUserInfoId: ctx.userInfoId,
      ),
    );
    await Audit.record(session,
        ctx: ctx, entityType: 'project', entityId: projectId, action: 'delete');
  }

  Future<Project> _requireLive(Session session, int projectId) async {
    final p = await Project.db.findById(session, projectId);
    if (p == null || p.deletedAt != null) {
      throw MakerflowNotFoundException(message: 'Project not found.');
    }
    return p;
  }
}
