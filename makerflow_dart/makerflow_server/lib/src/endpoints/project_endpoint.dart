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
}
