import 'models.dart';

/// Repository seam between the UI and the backend.
///
/// [InMemoryTaskRepository] lets the Flutter UI run TODAY, before the Serverpod
/// client is generated. The production implementation — [ServerpodTaskRepository]
/// (stubbed below) — wraps `client.task.*` from the generated `makerflow_client`
/// and is dropped in by flipping the provider in state/providers.dart.
abstract class TaskRepository {
  Future<List<TaskVm>> list(int organizationId, {int? projectId});
  Future<TaskVm> move(int taskId, String toStatus, double toSortOrder);
}

class InMemoryTaskRepository implements TaskRepository {
  final List<TaskVm> _tasks = [
    TaskVm(id: 1, organizationId: 1, title: 'Laser cutter monthly PM', status: 'todo', priority: 'high', assigneeName: 'Sam'),
    TaskVm(id: 2, organizationId: 1, title: 'Restock 3mm plywood', status: 'backlog', priority: 'medium', assigneeName: 'Jo'),
    TaskVm(id: 3, organizationId: 1, title: 'Onboard fall student cohort', status: 'inProgress', priority: 'high', assigneeName: 'Pat'),
    TaskVm(id: 4, organizationId: 1, title: 'Fix dust collector sensor', status: 'blocked', priority: 'urgent', assigneeName: 'Sam'),
    TaskVm(id: 5, organizationId: 1, title: 'Publish Q3 usage report', status: 'inReview', priority: 'low', assigneeName: 'Jo'),
    TaskVm(id: 6, organizationId: 1, title: 'Archive completed capstones', status: 'done', priority: 'low', assigneeName: 'Pat'),
  ];

  @override
  Future<List<TaskVm>> list(int organizationId, {int? projectId}) async =>
      _tasks.where((t) => t.organizationId == organizationId).toList();

  @override
  Future<TaskVm> move(int taskId, String toStatus, double toSortOrder) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    _tasks[i] = _tasks[i].copyWith(
      status: toStatus,
      sortOrder: toSortOrder,
      version: _tasks[i].version + 1,
    );
    return _tasks[i];
  }
}

/// Production implementation — wraps the generated Serverpod client.
/// Uncomment the makerflow_client dependency in pubspec.yaml, run
/// `serverpod generate`, then implement against `client.task.*`.
///
/// class ServerpodTaskRepository implements TaskRepository {
///   ServerpodTaskRepository(this.client);
///   final Client client;
///   @override
///   Future<List<TaskVm>> list(int orgId, {int? projectId}) async {
///     final rows = await client.task.list(orgId, projectId: projectId);
///     return rows.map(_toVm).toList();
///   }
///   @override
///   Future<TaskVm> move(int id, String status, double order) async {
///     final row = await client.task.move(id, TaskStatus.values.byName(status), order);
///     return _toVm(row);
///   }
/// }
