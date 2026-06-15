import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';
import 'task_endpoint.dart' show MakerflowNotFoundException;

/// Onboarding templates → assignments. Templates are manager-managed; an
/// assignee (student+) can advance their own assignment's state.
class OnboardingEndpoint extends Endpoint {
  Future<List<OnboardingTemplate>> templates(Session session, int organizationId) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return OnboardingTemplate.db.find(
      session,
      where: (t) => t.organizationId.equals(organizationId) & t.deletedAt.equals(null),
      orderBy: (t) => t.name,
    );
  }

  Future<OnboardingTemplate> saveTemplate(Session session, OnboardingTemplate draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.manager);
    final now = DateTime.now().toUtc();
    final isNew = draft.id == null;
    final saved = isNew
        ? await OnboardingTemplate.db.insertRow(session, draft.copyWith(createdAt: now, updatedAt: now))
        : await OnboardingTemplate.db.updateRow(session, draft.copyWith(updatedAt: now));
    await Audit.record(session,
        ctx: ctx, entityType: 'onboardingTemplate', entityId: saved.id, action: isNew ? 'create' : 'update');
    return saved;
  }

  Future<OnboardingAssignment> assign(
      Session session, int organizationId, int templateId, int assigneeUserInfoId, DateTime? dueAt) async {
    final ctx = await RbacGuard.requireRole(session, organizationId, MembershipRole.manager);
    final now = DateTime.now().toUtc();
    final saved = await OnboardingAssignment.db.insertRow(
      session,
      OnboardingAssignment(
        organizationId: organizationId,
        templateId: templateId,
        assigneeUserInfoId: assigneeUserInfoId,
        state: OnboardingState.notStarted,
        dueAt: dueAt,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await Audit.record(session,
        ctx: ctx, entityType: 'onboardingAssignment', entityId: saved.id, action: 'create',
        summary: 'assignee=$assigneeUserInfoId');
    return saved;
  }

  /// Advance state. The assignee may update their own; managers may update any.
  Future<OnboardingAssignment> setState(
      Session session, int assignmentId, OnboardingState state, String? progressJson) async {
    final a = await OnboardingAssignment.db.findById(session, assignmentId);
    if (a == null) throw const MakerflowNotFoundException('Assignment not found.');
    final ctx = await RbacGuard.requireRole(session, a.organizationId, MembershipRole.student);
    final isSelf = a.assigneeUserInfoId == ctx.userInfoId;
    final isManager = RbacGuard.atLeast(ctx.role, MembershipRole.manager) || ctx.isSuperuser;
    if (!isSelf && !isManager) {
      throw const MakerflowForbiddenException('Only the assignee or a manager may update this.');
    }
    final now = DateTime.now().toUtc();
    final saved = await OnboardingAssignment.db.updateRow(
      session,
      a.copyWith(
        state: state,
        progressJson: progressJson ?? a.progressJson,
        completedAt: state == OnboardingState.completed ? now : a.completedAt,
        updatedAt: now,
      ),
    );
    await Audit.record(session,
        ctx: ctx, entityType: 'onboardingAssignment', entityId: assignmentId, action: 'update',
        summary: 'state=${state.name}');
    return saved;
  }
}
