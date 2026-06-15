import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/rbac.dart';
import 'task_endpoint.dart' show MakerflowNotFoundException;

/// Equipment assets — maintenance + certification tracking. Same security
/// contract as TaskEndpoint (requireRole → org-scope → audit → soft-delete).
class EquipmentEndpoint extends Endpoint {
  Future<List<EquipmentAsset>> list(Session session, int organizationId,
      {EquipmentStatus? status}) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return EquipmentAsset.db.find(
      session,
      where: (e) {
        var w = e.organizationId.equals(organizationId) & e.deletedAt.equals(null);
        if (status != null) w &= e.status.equals(status);
        return w;
      },
      orderBy: (e) => e.name,
    );
  }

  Future<EquipmentAsset> save(Session session, EquipmentAsset draft) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.staff);
    final now = DateTime.now().toUtc();
    final isNew = draft.id == null;
    final EquipmentAsset saved;
    if (isNew) {
      saved = await EquipmentAsset.db.insertRow(
        session,
        draft.copyWith(version: 1, createdAt: now, updatedAt: now, createdByUserInfoId: ctx.userInfoId),
      );
    } else {
      final existing = await EquipmentAsset.db.findById(session, draft.id!);
      if (existing == null || existing.deletedAt != null) {
        throw const MakerflowNotFoundException('Equipment not found.');
      }
      saved = await EquipmentAsset.db.updateRow(
        session,
        draft.copyWith(
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
        entityType: 'equipmentAsset',
        entityId: saved.id,
        action: isNew ? 'create' : 'update');
    return saved;
  }

  Future<void> softDelete(Session session, int id) async {
    final existing = await EquipmentAsset.db.findById(session, id);
    if (existing == null || existing.deletedAt != null) return;
    final ctx = await RbacGuard.requireRole(
        session, existing.organizationId, MembershipRole.staff);
    await EquipmentAsset.db.updateRow(session,
        existing.copyWith(deletedAt: DateTime.now().toUtc(), deletedByUserInfoId: ctx.userInfoId));
    await Audit.record(session,
        ctx: ctx, entityType: 'equipmentAsset', entityId: id, action: 'delete');
  }
}
