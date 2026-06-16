import 'models.dart';

/// Repository seam between the UI and the backend.
///
/// [InMemoryTaskRepository] lets the Flutter UI run with no server. The live
/// implementation is [ServerpodTaskRepository] (serverpod_task_repository.dart),
/// which wraps `client.task.*` from the generated `makerflow_client`; it's
/// selected in state/providers.dart when `--dart-define=MAKERFLOW_LIVE=true`.
abstract class TaskRepository {
  Future<List<TaskVm>> list(int organizationId, {int? projectId});
  Future<TaskVm> move(int taskId, String toStatus, double toSortOrder);

  /// Create a task. Returns the persisted row (with its server-assigned id).
  /// Server enforces staff+; the UI surfaces the typed failure.
  Future<TaskVm> create({
    required int organizationId,
    required String title,
    required String status,
    required String priority,
    int? projectId,
  });
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

  @override
  Future<TaskVm> create({
    required int organizationId,
    required String title,
    required String status,
    required String priority,
    int? projectId,
  }) async {
    final nextId = _tasks.fold<int>(0, (m, t) => t.id > m ? t.id : m) + 1;
    final created = TaskVm(
      id: nextId,
      organizationId: organizationId,
      title: title,
      status: status,
      priority: priority,
      projectId: projectId,
    );
    _tasks.add(created);
    return created;
  }
}
