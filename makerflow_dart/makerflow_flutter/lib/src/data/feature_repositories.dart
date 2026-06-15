import 'feature_models.dart';

/// Repository seam for the operations features. In-memory impls let the UI run
/// before `serverpod generate`; the production impls wrap the generated client
/// (client.org.*, client.equipment.*, client.consumable.*, client.meeting.*).
/// See task_repository.dart for the swap pattern.

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
}

class InMemoryEquipmentRepository implements EquipmentRepository {
  @override
  Future<List<EquipmentVm>> list(int orgId) async => [
        EquipmentVm(id: 1, name: 'Glowforge laser', status: 'operational', space: 'Main bay'),
        EquipmentVm(id: 2, name: 'Haas CNC mill', status: 'maintenanceDue', space: 'Machine shop'),
        EquipmentVm(id: 3, name: 'Dust collector', status: 'outOfService', space: 'Machine shop'),
      ];
}

abstract class ConsumableRepository {
  Future<List<ConsumableVm>> list(int orgId);
}

class InMemoryConsumableRepository implements ConsumableRepository {
  @override
  Future<List<ConsumableVm>> list(int orgId) async => [
        ConsumableVm(id: 1, name: '3mm plywood', status: 'reorder', quantityOnHand: 4, reorderPoint: 10, unit: 'sheets'),
        ConsumableVm(id: 2, name: 'PLA filament', status: 'inStock', quantityOnHand: 22, reorderPoint: 8, unit: 'spools'),
        ConsumableVm(id: 3, name: 'Cut-resistant gloves', status: 'low', quantityOnHand: 6, reorderPoint: 6, unit: 'pairs'),
      ];
}

abstract class MeetingRepository {
  Future<List<MeetingVm>> list(int orgId);
}

class InMemoryMeetingRepository implements MeetingRepository {
  @override
  Future<List<MeetingVm>> list(int orgId) async => [
        MeetingVm(id: 1, title: 'Weekly staff sync', status: 'active'),
        MeetingVm(id: 2, title: 'Safety committee', status: 'draft'),
      ];
}
