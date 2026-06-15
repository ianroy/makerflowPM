import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';
import '../business/channels.dart';

/// Comments + watchers on any entity, plus a streaming activity feed that
/// replaces the legacy poll/refresh helper. Comments are announced to watchers
/// via the realtime channel (Appendix C); the client surfaces them in a live
/// region (WCAG 4.1.3).
class CollabEndpoint extends Endpoint {
  Future<List<ItemComment>> comments(
      Session session, int organizationId, String entityType, int entityId) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return ItemComment.db.find(
      session,
      where: (c) =>
          c.organizationId.equals(organizationId) &
          c.entityType.equals(entityType) &
          c.entityId.equals(entityId) &
          c.deletedAt.equals(null),
      orderBy: (c) => c.createdAt,
    );
  }

  /// Add a comment (student+ may comment). Publishes an activity event.
  Future<ItemComment> addComment(Session session, ItemComment draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.student);
    final now = DateTime.now().toUtc();
    final saved = await ItemComment.db.insertRow(
      session,
      draft.copyWith(
        version: 1,
        createdAt: now,
        updatedAt: now,
        createdByUserInfoId: ctx.userInfoId,
        deletedAt: null,
        deletedByUserInfoId: null,
      ),
    );
    await Audit.record(session,
        ctx: ctx,
        entityType: 'itemComment',
        entityId: saved.id,
        action: 'create',
        summary: 'on ${saved.entityType}#${saved.entityId}');
    await Channels.publish(
      session,
      organizationId: ctx.organizationId,
      event: ChangeEvent(
        entityType: 'itemComment',
        entityId: saved.id!,
        op: 'create',
        version: saved.version,
        updatedAt: saved.updatedAt,
      ),
    );
    return saved;
  }

  /// Follow/unfollow an entity (drives push fan-out, fl-5-push).
  Future<void> watch(Session session, int organizationId, String entityType,
      int entityId, bool watching) async {
    final ctx =
        await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    final existing = await ItemWatcher.db.findFirstRow(
      session,
      where: (w) =>
          w.organizationId.equals(organizationId) &
          w.entityType.equals(entityType) &
          w.entityId.equals(entityId) &
          w.userInfoId.equals(ctx.userInfoId),
    );
    if (watching && existing == null) {
      await ItemWatcher.db.insertRow(
        session,
        ItemWatcher(
          organizationId: organizationId,
          entityType: entityType,
          entityId: entityId,
          userInfoId: ctx.userInfoId,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } else if (!watching && existing != null) {
      await ItemWatcher.db.deleteRow(session, existing);
    }
  }

  /// Streaming activity feed for the active org. Each event is a compact
  /// change notice the client applies to local state.
  Stream<ChangeEvent> activityStream(Session session, int organizationId) async* {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    yield* Channels.subscribe(session, organizationId: organizationId);
  }
}
