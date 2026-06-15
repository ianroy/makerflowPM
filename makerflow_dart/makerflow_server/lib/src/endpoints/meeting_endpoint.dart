import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';
import 'task_endpoint.dart' show MakerflowNotFoundException;

/// Meetings & agendas. Items can be **converted** into a task or project — the
/// meeting → execution bridge. Replaces /agenda* and /api/agenda*.
class MeetingEndpoint extends Endpoint {
  Future<List<MeetingAgenda>> agendas(Session session, int organizationId) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return MeetingAgenda.db.find(
      session,
      where: (a) => a.organizationId.equals(organizationId) & a.deletedAt.equals(null),
      orderBy: (a) => a.meetingAt,
      orderDescending: true,
    );
  }

  Future<List<MeetingItem>> items(Session session, int organizationId, int agendaId) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return MeetingItem.db.find(
      session,
      where: (i) =>
          i.organizationId.equals(organizationId) &
          i.agendaId.equals(agendaId) &
          i.deletedAt.equals(null),
      orderBy: (i) => i.sortOrder,
    );
  }

  Future<MeetingAgenda> saveAgenda(Session session, MeetingAgenda draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.staff);
    final now = DateTime.now().toUtc();
    final isNew = draft.id == null;
    final saved = isNew
        ? await MeetingAgenda.db.insertRow(session,
            draft.copyWith(createdAt: now, updatedAt: now, createdByUserInfoId: ctx.userInfoId))
        : await MeetingAgenda.db.updateRow(session, draft.copyWith(updatedAt: now));
    await Audit.record(session,
        ctx: ctx, entityType: 'meetingAgenda', entityId: saved.id, action: isNew ? 'create' : 'update');
    return saved;
  }

  Future<MeetingItem> saveItem(Session session, MeetingItem draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.staff);
    final now = DateTime.now().toUtc();
    final isNew = draft.id == null;
    final saved = isNew
        ? await MeetingItem.db.insertRow(session,
            draft.copyWith(createdAt: now, updatedAt: now, createdByUserInfoId: ctx.userInfoId))
        : await MeetingItem.db.updateRow(session, draft.copyWith(updatedAt: now));
    await Audit.record(session,
        ctx: ctx, entityType: 'meetingItem', entityId: saved.id, action: isNew ? 'create' : 'update');
    return saved;
  }

  /// Convert a meeting item into a Task (the execution bridge). Links the new
  /// task back onto the item so the agenda shows what it became.
  Future<Task> convertItemToTask(Session session, int organizationId, int itemId) async {
    final ctx =
        await RbacGuard.requireRole(session, organizationId, MembershipRole.staff);
    final item = await MeetingItem.db.findById(session, itemId);
    if (item == null || item.organizationId != organizationId || item.deletedAt != null) {
      throw const MakerflowNotFoundException('Meeting item not found.');
    }
    final now = DateTime.now().toUtc();
    final task = await Task.db.insertRow(
      session,
      Task(
        organizationId: organizationId,
        title: item.title,
        description: item.notes,
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        sortOrder: 0,
        version: 1,
        createdAt: now,
        updatedAt: now,
        createdByUserInfoId: ctx.userInfoId,
      ),
    );
    await MeetingItem.db.updateRow(
      session,
      item.copyWith(linkedTaskId: task.id, status: 'actioned', updatedAt: now),
    );
    await Audit.record(session,
        ctx: ctx,
        entityType: 'meetingItem',
        entityId: itemId,
        action: 'convert',
        summary: 'to task#${task.id}');
    return task;
  }
}
