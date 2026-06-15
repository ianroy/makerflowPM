import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';
import 'task_endpoint.dart' show MakerflowNotFoundException;

/// Scored intake queue. Feature-flagged at the app layer (matches the legacy
/// FEATURE_INTAKE_ENABLED). Items can convert into a project.
class IntakeEndpoint extends Endpoint {
  Future<List<IntakeRequest>> list(Session session, int organizationId) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return IntakeRequest.db.find(
      session,
      where: (r) => r.organizationId.equals(organizationId) & r.deletedAt.equals(null),
      orderBy: (r) => r.score,
      orderDescending: true,
    );
  }

  Future<IntakeRequest> save(Session session, IntakeRequest draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.staff);
    final now = DateTime.now().toUtc();
    final isNew = draft.id == null;
    final saved = isNew
        ? await IntakeRequest.db.insertRow(session,
            draft.copyWith(createdAt: now, updatedAt: now, createdByUserInfoId: ctx.userInfoId))
        : await IntakeRequest.db.updateRow(session, draft.copyWith(updatedAt: now));
    await Audit.record(session,
        ctx: ctx, entityType: 'intakeRequest', entityId: saved.id, action: isNew ? 'create' : 'update');
    return saved;
  }

  Future<Project> convertToProject(Session session, int organizationId, int requestId) async {
    final ctx = await RbacGuard.requireRole(session, organizationId, MembershipRole.staff);
    final r = await IntakeRequest.db.findById(session, requestId);
    if (r == null || r.organizationId != organizationId || r.deletedAt != null) {
      throw const MakerflowNotFoundException('Intake request not found.');
    }
    final now = DateTime.now().toUtc();
    final project = await Project.db.insertRow(
      session,
      Project(
        organizationId: organizationId,
        name: r.title,
        status: 'planned',
        priority: TaskPriority.medium,
        createdAt: now,
        updatedAt: now,
        createdByUserInfoId: ctx.userInfoId,
      ),
    );
    await IntakeRequest.db.updateRow(
      session,
      r.copyWith(stage: IntakeStage.converted, convertedProjectId: project.id, updatedAt: now),
    );
    await Audit.record(session,
        ctx: ctx, entityType: 'intakeRequest', entityId: requestId, action: 'convert',
        summary: 'to project#${project.id}');
    return project;
  }
}
