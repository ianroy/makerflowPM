import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';

/// Task CRUD + kanban move. Every method enforces the security contract:
/// authenticate → requireRole → org-scope every query → audit mutations →
/// soft-delete (never hard-delete here).
///
/// Replaces the legacy /tasks, /tasks/new, /tasks/update, /api/tasks* routes.
class TaskEndpoint extends Endpoint {
  /// List non-deleted tasks for an org, optionally filtered by project/status.
  Future<List<Task>> list(
    Session session,
    int organizationId, {
    int? projectId,
    TaskStatus? status,
  }) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return Task.db.find(
      session,
      where: (t) {
        var w = t.organizationId.equals(organizationId) &
            t.deletedAt.equals(null);
        if (projectId != null) w &= t.projectId.equals(projectId);
        if (status != null) w &= t.status.equals(status);
        return w;
      },
      orderBy: (t) => t.sortOrder,
    );
  }

  /// Create a task. Requires `staff`+ (students create only via their own
  /// scoped flow — modeled in fl-1; viewer/student blocked here).
  Future<Task> create(Session session, Task draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.staff);
    final now = DateTime.now().toUtc();
    final toInsert = draft.copyWith(
      version: 1,
      createdAt: now,
      updatedAt: now,
      createdByUserInfoId: ctx.userInfoId,
      deletedAt: null,
      deletedByUserInfoId: null,
    );
    final saved = await Task.db.insertRow(session, toInsert);
    await Audit.record(session,
        ctx: ctx,
        entityType: 'task',
        entityId: saved.id,
        action: 'create',
        payload: {'title': saved.title, 'status': saved.status.name});
    return saved;
  }

  /// Update a task. Optimistic-concurrency aware via [Task.version]:
  /// throws if the client's base version is stale (offline reconcile, R5).
  Future<Task> update(Session session, Task incoming) async {
    final incomingId = incoming.id;
    if (incomingId == null) {
      throw const MakerflowNotFoundException('Task id is required for update.');
    }
    final existing = await _requireLive(session, incomingId);
    final ctx = await RbacGuard.requireRole(
        session, existing.organizationId, MembershipRole.staff);

    if (incoming.version != existing.version) {
      throw const MakerflowConflictException(
        'Task was modified by someone else. Reload and retry.',
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
    final saved = await Task.db.updateRow(session, updated);
    await Audit.record(session,
        ctx: ctx,
        entityType: 'task',
        entityId: saved.id,
        action: 'update',
        payload: {'status': saved.status.name, 'version': saved.version});
    return saved;
  }

  /// Kanban move: change status and reorder. Used by both drag-and-drop and
  /// the keyboard move pattern (fl-1-projects-tasks, WCAG 2.1.1 / 2.5.1).
  Future<Task> move(
    Session session,
    int taskId,
    TaskStatus toStatus,
    double toSortOrder,
  ) async {
    final existing = await _requireLive(session, taskId);
    final ctx = await RbacGuard.requireRole(
        session, existing.organizationId, MembershipRole.staff);
    final saved = await Task.db.updateRow(
      session,
      existing.copyWith(
        status: toStatus,
        sortOrder: toSortOrder,
        version: existing.version + 1,
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    await Audit.record(session,
        ctx: ctx,
        entityType: 'task',
        entityId: taskId,
        action: 'move',
        summary: 'to ${toStatus.name}');
    return saved;
  }

  /// Soft-delete (goes to the trash queue; never a hard delete here).
  Future<void> softDelete(Session session, int taskId) async {
    final existing = await _requireLive(session, taskId);
    final ctx = await RbacGuard.requireRole(
        session, existing.organizationId, MembershipRole.staff);
    await Task.db.updateRow(
      session,
      existing.copyWith(
        deletedAt: DateTime.now().toUtc(),
        deletedByUserInfoId: ctx.userInfoId,
      ),
    );
    await Audit.record(session,
        ctx: ctx, entityType: 'task', entityId: taskId, action: 'delete');
  }

  Future<Task> _requireLive(Session session, int taskId) async {
    final t = await Task.db.findById(session, taskId);
    if (t == null || t.deletedAt != null) {
      throw const MakerflowNotFoundException('Task not found.');
    }
    return t;
  }
}

class MakerflowConflictException implements Exception {
  const MakerflowConflictException(this.message);
  final String message;
  @override
  String toString() => 'MakerflowConflictException: $message';
}

class MakerflowNotFoundException implements Exception {
  const MakerflowNotFoundException(this.message);
  final String message;
  @override
  String toString() => 'MakerflowNotFoundException: $message';
}
