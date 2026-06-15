import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';
import 'task_endpoint.dart' show MakerflowNotFoundException;

/// Partnerships pipeline. Manager+ to mutate (it's a relationship/governance
/// surface), viewer+ to read.
class PartnershipEndpoint extends Endpoint {
  Future<List<Partnership>> list(Session session, int organizationId,
      {PartnershipStage? stage}) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return Partnership.db.find(
      session,
      where: (p) {
        var w = p.organizationId.equals(organizationId) & p.deletedAt.equals(null);
        if (stage != null) w &= p.stage.equals(stage);
        return w;
      },
      orderBy: (p) => p.nextFollowUpAt,
    );
  }

  Future<Partnership> save(Session session, Partnership draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.manager);
    final now = DateTime.now().toUtc();
    final isNew = draft.id == null;
    final saved = isNew
        ? await Partnership.db.insertRow(session,
            draft.copyWith(createdAt: now, updatedAt: now, createdByUserInfoId: ctx.userInfoId))
        : await Partnership.db.updateRow(session, draft.copyWith(updatedAt: now));
    await Audit.record(session,
        ctx: ctx, entityType: 'partnership', entityId: saved.id, action: isNew ? 'create' : 'update');
    return saved;
  }

  Future<void> softDelete(Session session, int id) async {
    final existing = await Partnership.db.findById(session, id);
    if (existing == null || existing.deletedAt != null) return;
    final ctx = await RbacGuard.requireRole(
        session, existing.organizationId, MembershipRole.manager);
    await Partnership.db.updateRow(session,
        existing.copyWith(deletedAt: DateTime.now().toUtc(), deletedByUserInfoId: ctx.userInfoId));
    await Audit.record(session, ctx: ctx, entityType: 'partnership', entityId: id, action: 'delete');
  }
}
