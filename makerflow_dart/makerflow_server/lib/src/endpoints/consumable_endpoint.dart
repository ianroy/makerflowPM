import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';

/// Consumables — stock + reorder tracking. Reorder status is derived on save so
/// the UI can show a non-color cue (WCAG 1.4.1).
class ConsumableEndpoint extends Endpoint {
  Future<List<Consumable>> list(Session session, int organizationId) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return Consumable.db.find(
      session,
      where: (c) => c.organizationId.equals(organizationId) & c.deletedAt.equals(null),
      orderBy: (c) => c.name,
    );
  }

  Future<Consumable> save(Session session, Consumable draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.staff);
    final now = DateTime.now().toUtc();
    final withStatus = draft.copyWith(status: _deriveStatus(draft));
    final isNew = withStatus.id == null;
    final Consumable saved;
    if (isNew) {
      saved = await Consumable.db.insertRow(
        session,
        withStatus.copyWith(version: 1, createdAt: now, updatedAt: now, createdByUserInfoId: ctx.userInfoId),
      );
    } else {
      final existing = await Consumable.db.findById(session, withStatus.id!);
      if (existing == null || existing.deletedAt != null) {
        throw MakerflowNotFoundException(message: 'Consumable not found.');
      }
      saved = await Consumable.db.updateRow(
        session,
        withStatus.copyWith(
          organizationId: existing.organizationId,
          version: existing.version + 1,
          createdAt: existing.createdAt,
          createdByUserInfoId: existing.createdByUserInfoId,
          updatedAt: now,
        ),
      );
    }
    await Audit.record(session,
        ctx: ctx,
        entityType: 'consumable',
        entityId: saved.id,
        action: isNew ? 'create' : 'update');
    return saved;
  }

  Future<void> softDelete(Session session, int id) async {
    final existing = await Consumable.db.findById(session, id);
    if (existing == null || existing.deletedAt != null) return;
    final ctx = await RbacGuard.requireRole(
        session, existing.organizationId, MembershipRole.staff);
    await Consumable.db.updateRow(session,
        existing.copyWith(deletedAt: DateTime.now().toUtc(), deletedByUserInfoId: ctx.userInfoId));
    await Audit.record(session,
        ctx: ctx, entityType: 'consumable', entityId: id, action: 'delete');
  }

  ConsumableStatus _deriveStatus(Consumable c) {
    if (c.quantityOnHand <= 0) return ConsumableStatus.outOfStock;
    if (c.quantityOnHand <= c.reorderPoint) return ConsumableStatus.reorder;
    if (c.quantityOnHand <= c.reorderPoint * 1.25) return ConsumableStatus.low;
    return ConsumableStatus.inStock;
  }
}
