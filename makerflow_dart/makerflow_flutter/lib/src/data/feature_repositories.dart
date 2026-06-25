import 'feature_models.dart';

/// Repository seam for the operations features. In-memory impls let the UI run
/// before/without a server; the live impls (serverpod_feature_repositories.dart)
/// wrap the generated client (client.org.*, client.equipment.*,
/// client.consumable.*, client.meeting.*) and are selected in providers.dart
/// when --dart-define=MAKERFLOW_LIVE=true.

abstract class OrgRepository {
  Future<List<OrgVm>> listMine();
}

class InMemoryOrgRepository implements OrgRepository {
  @override
  Future<List<OrgVm>> listMine() async =>
      [OrgVm(id: 1, name: 'Brandeis MakerLab'), OrgVm(id: 2, name: 'Physics Shop')];
}

abstract class ProjectRepository {
  Future<List<ProjectVm>> list(int orgId);
}

class InMemoryProjectRepository implements ProjectRepository {
  @override
  Future<List<ProjectVm>> list(int orgId) async => [
        ProjectVm(id: 1, name: 'Fall capstone cohort', status: 'active', lane: 'build'),
        ProjectVm(id: 2, name: 'Shop safety refresh', status: 'planned', lane: 'discovery'),
        ProjectVm(id: 3, name: 'Open-house build night', status: 'onHold', lane: 'operate'),
      ];
}

abstract class EquipmentRepository {
  Future<List<EquipmentVm>> list(int orgId);
  Future<EquipmentVm> create({
    required int orgId,
    required String name,
    required String status,
  });
  Future<EquipmentVm> update({
    required int id,
    required int orgId,
    required String name,
    required String status,
  });
}

class InMemoryEquipmentRepository implements EquipmentRepository {
  final List<EquipmentVm> _items = [
    EquipmentVm(id: 1, name: 'Glowforge laser', status: 'operational', space: 'Main bay'),
    EquipmentVm(id: 2, name: 'Haas CNC mill', status: 'maintenanceDue', space: 'Machine shop'),
    EquipmentVm(id: 3, name: 'Dust collector', status: 'outOfService', space: 'Machine shop'),
  ];

  @override
  Future<List<EquipmentVm>> list(int orgId) async => List.unmodifiable(_items);

  @override
  Future<EquipmentVm> create({
    required int orgId,
    required String name,
    required String status,
  }) async {
    final created = EquipmentVm(id: _nextId(_items.map((e) => e.id)), name: name, status: status);
    _items.add(created);
    return created;
  }

  @override
  Future<EquipmentVm> update({
    required int id,
    required int orgId,
    required String name,
    required String status,
  }) async {
    final i = _items.indexWhere((e) => e.id == id);
    final updated = EquipmentVm(id: id, name: name, status: status, space: _items[i].space);
    _items[i] = updated;
    return updated;
  }
}

abstract class ConsumableRepository {
  Future<List<ConsumableVm>> list(int orgId);
  Future<ConsumableVm> create({
    required int orgId,
    required String name,
    required double quantityOnHand,
    required double reorderPoint,
    String? unit,
  });
  Future<ConsumableVm> update({
    required int id,
    required int orgId,
    required String name,
    required double quantityOnHand,
    required double reorderPoint,
    String? unit,
  });
}

class InMemoryConsumableRepository implements ConsumableRepository {
  final List<ConsumableVm> _items = [
    ConsumableVm(id: 1, name: '3mm plywood', status: 'reorder', quantityOnHand: 4, reorderPoint: 10, unit: 'sheets'),
    ConsumableVm(id: 2, name: 'PLA filament', status: 'inStock', quantityOnHand: 22, reorderPoint: 8, unit: 'spools'),
    ConsumableVm(id: 3, name: 'Cut-resistant gloves', status: 'low', quantityOnHand: 6, reorderPoint: 6, unit: 'pairs'),
  ];

  @override
  Future<List<ConsumableVm>> list(int orgId) async => List.unmodifiable(_items);

  @override
  Future<ConsumableVm> create({
    required int orgId,
    required String name,
    required double quantityOnHand,
    required double reorderPoint,
    String? unit,
  }) async {
    final created = ConsumableVm(
      id: _nextId(_items.map((e) => e.id)),
      name: name,
      // Mirror the server's derived reorder status (live impl gets it from the server).
      status: quantityOnHand <= 0
          ? 'outOfStock'
          : quantityOnHand <= reorderPoint
              ? 'reorder'
              : 'inStock',
      quantityOnHand: quantityOnHand,
      reorderPoint: reorderPoint,
      unit: unit,
    );
    _items.add(created);
    return created;
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
    final i = _items.indexWhere((e) => e.id == id);
    final updated = ConsumableVm(
      id: id,
      name: name,
      status: quantityOnHand <= 0
          ? 'outOfStock'
          : quantityOnHand <= reorderPoint
              ? 'reorder'
              : 'inStock',
      quantityOnHand: quantityOnHand,
      reorderPoint: reorderPoint,
      unit: unit,
    );
    _items[i] = updated;
    return updated;
  }
}

abstract class MeetingRepository {
  Future<List<MeetingVm>> list(int orgId);
  Future<MeetingVm> create({
    required int orgId,
    required String title,
    required String status,
  });
  Future<MeetingVm> update({
    required int id,
    required int orgId,
    required String title,
    required String status,
  });
}

class InMemoryMeetingRepository implements MeetingRepository {
  final List<MeetingVm> _items = [
    MeetingVm(id: 1, title: 'Weekly staff sync', status: 'active'),
    MeetingVm(id: 2, title: 'Safety committee', status: 'draft'),
  ];

  @override
  Future<List<MeetingVm>> list(int orgId) async => List.unmodifiable(_items);

  @override
  Future<MeetingVm> create({
    required int orgId,
    required String title,
    required String status,
  }) async {
    final created = MeetingVm(id: _nextId(_items.map((e) => e.id)), title: title, status: status);
    _items.add(created);
    return created;
  }

  @override
  Future<MeetingVm> update({
    required int id,
    required int orgId,
    required String title,
    required String status,
  }) async {
    final i = _items.indexWhere((e) => e.id == id);
    final updated = MeetingVm(id: id, title: title, status: status, meetingAt: _items[i].meetingAt);
    _items[i] = updated;
    return updated;
  }
}

int _nextId(Iterable<int> ids) => ids.fold<int>(0, (m, id) => id > m ? id : m) + 1;
