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

  /// Edit a task. [version] is the row the edit is based on — the server
  /// rejects a stale version with a conflict (optimistic concurrency, R5).
  /// [sortOrder] is passed through unchanged so an edit never reorders the card.
  /// [dueAt]: null = leave unchanged (clearing a date is a copyWith limitation,
  /// tracked in the plan).
  Future<TaskVm> update({
    required int id,
    required int version,
    required int organizationId,
    required String title,
    required String status,
    required String priority,
    required double sortOrder,
    int? projectId,
    DateTime? dueAt,
  });

  /// Soft-delete: the task leaves the board but is restorable from the trash.
  Future<void> softDelete(int taskId);
}

class InMemoryTaskRepository implements TaskRepository {
  final List<TaskVm> _tasks = [
    TaskVm(id: 1, organizationId: 1, title: 'Laser cutter monthly PM', status: 'todo', priority: 'high', assigneeName: 'Sam', dueAt: DateTime(2026, 7, 18)),
    TaskVm(id: 2, organizationId: 1, title: 'Restock 3mm plywood', status: 'backlog', priority: 'medium', assigneeName: 'Jo'),
    TaskVm(id: 3, organizationId: 1, title: 'Onboard fall student cohort', status: 'inProgress', priority: 'high', assigneeName: 'Pat', projectId: 1, dueAt: DateTime(2026, 7, 21)),
    TaskVm(id: 4, organizationId: 1, title: 'Fix dust collector sensor', status: 'blocked', priority: 'urgent', assigneeName: 'Sam'),
    TaskVm(id: 5, organizationId: 1, title: 'Publish Q3 usage report', status: 'inReview', priority: 'low', assigneeName: 'Jo'),
    TaskVm(id: 6, organizationId: 1, title: 'Archive completed capstones', status: 'done', priority: 'low', assigneeName: 'Pat', projectId: 1),
  ];

  @override
  Future<List<TaskVm>> list(int organizationId, {int? projectId}) async => _tasks
      .where((t) =>
          t.organizationId == organizationId &&
          (projectId == null || t.projectId == projectId))
      .toList();

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

  @override
  Future<TaskVm> update({
    required int id,
    required int version,
    required int organizationId,
    required String title,
    required String status,
    required String priority,
    required double sortOrder,
    int? projectId,
    DateTime? dueAt,
  }) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    final updated = TaskVm(
      id: id,
      organizationId: organizationId,
      title: title,
      status: status,
      priority: priority,
      projectId: projectId ?? _tasks[i].projectId,
      assigneeName: _tasks[i].assigneeName,
      dueAt: dueAt ?? _tasks[i].dueAt,
      sortOrder: sortOrder,
      version: version + 1,
    );
    _tasks[i] = updated;
    return updated;
  }

  @override
  Future<void> softDelete(int taskId) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i >= 0) _deleted.add(_tasks.removeAt(i));
  }

  // --- trash store (shared with InMemoryTrashRepository via the same instance,
  // so soft-delete in the stub coordinates like the live DB does) ---
  final List<TaskVm> _deleted = [];

  List<TaskVm> deletedFor(int organizationId) =>
      _deleted.where((t) => t.organizationId == organizationId).toList();

  void restore(int taskId) {
    final i = _deleted.indexWhere((t) => t.id == taskId);
    if (i >= 0) _tasks.add(_deleted.removeAt(i));
  }

  void purge(int taskId) => _deleted.removeWhere((t) => t.id == taskId);
}
