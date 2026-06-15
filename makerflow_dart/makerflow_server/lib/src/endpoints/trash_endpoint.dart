import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';
import 'task_endpoint.dart' show MakerflowNotFoundException;

/// The deleted queue (/deleted): list soft-deleted rows, restore, or
/// permanently purge. Restore is staff+; purge is workspace_admin+ (matches
/// docs/SECURITY.md). v1 covers tasks + projects; extend per entity.
class TrashEndpoint extends Endpoint {
  Future<List<Task>> deletedTasks(Session session, int organizationId) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.staff);
    return Task.db.find(
      session,
      where: (t) => t.organizationId.equals(organizationId) & (t.deletedAt.notEquals(null)),
      orderBy: (t) => t.deletedAt,
      orderDescending: true,
    );
  }

  Future<Task> restoreTask(Session session, int id) async {
    final t = await Task.db.findById(session, id);
    if (t == null) throw const MakerflowNotFoundException('Task not found.');
    final ctx = await RbacGuard.requireRole(
        session, t.organizationId, MembershipRole.staff);
    final saved = await Task.db.updateRow(session,
        t.copyWith(deletedAt: null, deletedByUserInfoId: null, updatedAt: DateTime.now().toUtc(), version: t.version + 1));
    await Audit.record(session, ctx: ctx, entityType: 'task', entityId: id, action: 'restore');
    return saved;
  }

  /// Permanent purge (workspace_admin+). Irreversible; audited (and the audit
  /// row itself is never purged).
  Future<void> purgeTask(Session session, int id) async {
    final t = await Task.db.findById(session, id);
    if (t == null) return;
    final ctx = await RbacGuard.requireRole(
        session, t.organizationId, MembershipRole.workspaceAdmin);
    await Task.db.deleteRow(session, t);
    await Audit.record(session, ctx: ctx, entityType: 'task', entityId: id, action: 'purge');
  }
}
