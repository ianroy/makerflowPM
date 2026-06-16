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
}
