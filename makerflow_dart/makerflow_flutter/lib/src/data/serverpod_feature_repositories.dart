import 'package:makerflow_client/makerflow_client.dart' as api;

import 'feature_models.dart';
import 'feature_repositories.dart';

/// Live implementations of the operations-feature repositories, backed by the
/// generated Serverpod client. Wired in when the app runs with
/// `--dart-define=MAKERFLOW_LIVE=true` (see state/providers.dart); the in-memory
/// impls in feature_repositories.dart remain the default so the app runs with
/// no server. Mirrors the proven ServerpodTaskRepository pattern.
///
/// All reads are org-scoped on the server (requireRole(viewer) → org filter), so
/// these just pass the active org id through and map rows → view models.

class ServerpodOrgRepository implements OrgRepository {
  ServerpodOrgRepository(this._client);
  final api.Client _client;

  @override
  Future<List<OrgVm>> listMine() async {
    final rows = await _client.org.listMine();
    return rows.map((o) => OrgVm(id: o.id ?? 0, name: o.name)).toList();
  }
}

class ServerpodProjectRepository implements ProjectRepository {
  ServerpodProjectRepository(this._client);
  final api.Client _client;

  @override
  Future<List<ProjectVm>> list(int orgId) async {
    final rows = await _client.project.list(orgId);
    return rows
        .map((p) => ProjectVm(
              id: p.id ?? 0,
              name: p.name,
              status: p.status,
              lane: p.lane,
            ))
        .toList();
  }
}

class ServerpodEquipmentRepository implements EquipmentRepository {
  ServerpodEquipmentRepository(this._client);
  final api.Client _client;

  @override
  Future<List<EquipmentVm>> list(int orgId) async {
    final rows = await _client.equipment.list(orgId);
    return rows
        .map((e) => EquipmentVm(
              id: e.id ?? 0,
              name: e.name,
              status: e.status.name,
              // The model carries spaceId (int); resolving it to a space *name*
              // needs a Space lookup — follow-up. Show the id-less name as null.
              space: null,
            ))
        .toList();
  }

  @override
  Future<EquipmentVm> create({
    required int orgId,
    required String name,
    required String status,
  }) async {
    final now = DateTime.now().toUtc();
    final saved = await _client.equipment.save(api.EquipmentAsset(
      organizationId: orgId,
      name: name,
      status: api.EquipmentStatus.values.byName(status),
      certificationRequired: false,
      version: 1,
      createdAt: now,
      updatedAt: now,
    ));
    return EquipmentVm(
        id: saved.id ?? 0, name: saved.name, status: saved.status.name, space: null);
  }

  @override
  Future<EquipmentVm> update({
    required int id,
    required int orgId,
    required String name,
    required String status,
  }) async {
    // Fetch-merge so an edit preserves server-only fields the VM doesn't carry
    // (assetTag, spaceId, certification, maintenance dates, notes).
    final existing = (await _client.equipment.list(orgId)).firstWhere((e) => e.id == id);
    final saved = await _client.equipment.save(existing.copyWith(
      name: name,
      status: api.EquipmentStatus.values.byName(status),
    ));
    return EquipmentVm(
        id: saved.id ?? 0, name: saved.name, status: saved.status.name, space: null);
  }
}

class ServerpodConsumableRepository implements ConsumableRepository {
  ServerpodConsumableRepository(this._client);
  final api.Client _client;

  @override
  Future<List<ConsumableVm>> list(int orgId) async {
    final rows = await _client.consumable.list(orgId);
    return rows
        .map((c) => ConsumableVm(
              id: c.id ?? 0,
              name: c.name,
              status: c.status.name,
              quantityOnHand: c.quantityOnHand,
              reorderPoint: c.reorderPoint,
              unit: c.unit,
            ))
        .toList();
  }

  @override
  Future<ConsumableVm> create({
    required int orgId,
    required String name,
    required double quantityOnHand,
    required double reorderPoint,
    String? unit,
  }) async {
    final now = DateTime.now().toUtc();
    final saved = await _client.consumable.save(api.Consumable(
      organizationId: orgId,
      name: name,
      unit: unit,
      quantityOnHand: quantityOnHand,
      reorderPoint: reorderPoint,
      // The server derives the real reorder status on save; this is a placeholder.
      status: api.ConsumableStatus.inStock,
      version: 1,
      createdAt: now,
      updatedAt: now,
    ));
    return ConsumableVm(
      id: saved.id ?? 0,
      name: saved.name,
      status: saved.status.name,
      quantityOnHand: saved.quantityOnHand,
      reorderPoint: saved.reorderPoint,
      unit: saved.unit,
    );
  }

  @override
  Future<ConsumableVm> update({
    required int id,
    required int orgId,
    required String name,
    required double quantityOnHand,
    required double reorderPoint,
    String? unit,
  }) async {
    // Fetch-merge (preserves spaceId/category); the server re-derives status.
    final existing = (await _client.consumable.list(orgId)).firstWhere((c) => c.id == id);
    final saved = await _client.consumable.save(existing.copyWith(
      name: name,
      quantityOnHand: quantityOnHand,
      reorderPoint: reorderPoint,
      unit: unit,
    ));
    return ConsumableVm(
      id: saved.id ?? 0,
      name: saved.name,
      status: saved.status.name,
      quantityOnHand: saved.quantityOnHand,
      reorderPoint: saved.reorderPoint,
      unit: saved.unit,
    );
  }
}

class ServerpodMeetingRepository implements MeetingRepository {
  ServerpodMeetingRepository(this._client);
  final api.Client _client;

  @override
  Future<List<MeetingVm>> list(int orgId) async {
    final rows = await _client.meeting.agendas(orgId);
    return rows
        .map((m) => MeetingVm(
              id: m.id ?? 0,
              title: m.title,
              status: m.status,
              meetingAt: m.meetingAt,
            ))
        .toList();
  }

  @override
  Future<MeetingVm> create({
    required int orgId,
    required String title,
    required String status,
  }) async {
    final now = DateTime.now().toUtc();
    final saved = await _client.meeting.saveAgenda(api.MeetingAgenda(
      organizationId: orgId,
      title: title,
      status: status,
      createdAt: now,
      updatedAt: now,
    ));
    return MeetingVm(
        id: saved.id ?? 0,
        title: saved.title,
        status: saved.status,
        meetingAt: saved.meetingAt);
  }

  @override
  Future<MeetingVm> update({
    required int id,
    required int orgId,
    required String title,
    required String status,
  }) async {
    // Fetch-merge so an edit keeps meetingAt/owner/team/space.
    final existing = (await _client.meeting.agendas(orgId)).firstWhere((m) => m.id == id);
    final saved = await _client.meeting.saveAgenda(existing.copyWith(title: title, status: status));
    return MeetingVm(
        id: saved.id ?? 0,
        title: saved.title,
        status: saved.status,
        meetingAt: saved.meetingAt);
  }
}
