/// Client view models for the operations features. Field-compatible with the
/// Serverpod models so the repository layer can swap in the generated client.
class OrgVm {
  OrgVm({required this.id, required this.name});
  final int id;
  final String name;
}

class ProjectVm {
  ProjectVm({required this.id, required this.name, required this.status, this.lane});
  final int id;
  final String name;
  final String status;
  final String? lane;
}

class EquipmentVm {
  EquipmentVm({required this.id, required this.name, required this.status, this.space});
  final int id;
  final String name;
  final String status; // operational | maintenanceDue | underMaintenance | outOfService | retired
  final String? space;
}

class ConsumableVm {
  ConsumableVm({
    required this.id,
    required this.name,
    required this.status,
    required this.quantityOnHand,
    required this.reorderPoint,
    this.unit,
  });
  final int id;
  final String name;
  final String status; // inStock | low | reorder | outOfStock
  final double quantityOnHand;
  final double reorderPoint;
  final String? unit;
}

class MeetingVm {
  MeetingVm({required this.id, required this.title, required this.status, this.meetingAt});
  final int id;
  final String title;
  final String status; // draft | active | closed
  final DateTime? meetingAt;
}
