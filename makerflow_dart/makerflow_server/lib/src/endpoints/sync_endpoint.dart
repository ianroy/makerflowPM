import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/pagination.dart';
import '../business/rbac.dart';

/// Offline sync (fl-5-offline-sync, Appendix C). The client PULLS deltas since
/// its [SyncCursor] and PUSHES queued mutations keyed by clientUuid. This
/// endpoint sketches the pull side for `task` (the first offline entity); push
/// + multi-entity + conflict resolution land in fl-5.
class SyncEndpoint extends Endpoint {
  /// Tasks changed since the device's cursor, ordered by (updatedAt, id).
  /// Includes soft-deleted rows as tombstones so the client can remove them.
  Future<TaskDeltaPage> pullTasks(
    Session session,
    int organizationId,
    String? cursor, {
    int? limit,
  }) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    final c = Cursor.decode(cursor);
    final lim = normalizeLimit(limit);

    final rows = await Task.db.find(
      session,
      where: (t) {
        var w = t.organizationId.equals(organizationId);
        if (c != null) {
          // keyset: updatedAt > cursor.updatedAt OR (== AND id > cursor.id)
          w &= (t.updatedAt > c.updatedAt) |
              (t.updatedAt.equals(c.updatedAt) & (t.id > c.id));
        }
        return w;
      },
      orderBy: (t) => t.updatedAt,
      limit: lim + 1,
    );

    final hasMore = rows.length > lim;
    final page = hasMore ? rows.sublist(0, lim) : rows;
    final next = hasMore && page.isNotEmpty
        ? Cursor(page.last.updatedAt, page.last.id!).encode()
        : null;

    return TaskDeltaPage(tasks: page, nextCursor: next);
  }

  /// Persist/advance this device's cursor after applying a page.
  Future<void> ackCursor(
    Session session,
    int organizationId,
    String deviceId,
    String cursor,
  ) async {
    final ctx =
        await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    final c = Cursor.decode(cursor);
    if (c == null) return;
    final existing = await SyncCursor.db.findFirstRow(
      session,
      where: (s) =>
          s.organizationId.equals(organizationId) &
          s.userInfoId.equals(ctx.userInfoId) &
          s.deviceId.equals(deviceId),
    );
    final now = DateTime.now().toUtc();
    if (existing == null) {
      await SyncCursor.db.insertRow(
        session,
        SyncCursor(
          organizationId: organizationId,
          userInfoId: ctx.userInfoId,
          deviceId: deviceId,
          lastUpdatedAt: c.updatedAt,
          lastId: c.id,
          updatedAt: now,
        ),
      );
    } else {
      await SyncCursor.db.updateRow(session,
          existing.copyWith(lastUpdatedAt: c.updatedAt, lastId: c.id, updatedAt: now));
    }
  }
}
