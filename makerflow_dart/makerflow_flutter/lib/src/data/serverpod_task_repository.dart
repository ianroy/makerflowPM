import 'package:makerflow_client/makerflow_client.dart' as api;

import 'models.dart';
import 'task_repository.dart';

/// Live [TaskRepository] backed by the generated Serverpod client. Wired in
/// when the app runs with `--dart-define=MAKERFLOW_LIVE=true` (see providers).
/// Auth-gated endpoints require an active serverpod_auth session — sign-in
/// lands with fl-0-auth-rbac-tenancy (client side).
class ServerpodTaskRepository implements TaskRepository {
  ServerpodTaskRepository(this._client);
  final api.Client _client;

  @override
  Future<List<TaskVm>> list(int organizationId, {int? projectId}) async {
    final rows = await _client.task.list(organizationId, projectId: projectId);
    return rows.map(_toVm).toList();
  }

  @override
  Future<TaskVm> move(int taskId, String toStatus, double toSortOrder) async {
    final row = await _client.task
        .move(taskId, api.TaskStatus.values.byName(toStatus), toSortOrder);
    return _toVm(row);
  }

  @override
  Future<TaskVm> create({
    required int organizationId,
    required String title,
    required String status,
    required String priority,
    int? projectId,
  }) async {
    // The server stamps version/timestamps/createdBy; these are placeholders.
    final now = DateTime.now().toUtc();
    final row = await _client.task.create(api.Task(
      organizationId: organizationId,
      title: title,
      status: api.TaskStatus.values.byName(status),
      priority: api.TaskPriority.values.byName(priority),
      projectId: projectId,
      sortOrder: 0,
      version: 1,
      createdAt: now,
      updatedAt: now,
    ));
    return _toVm(row);
  }

  TaskVm _toVm(api.Task t) => TaskVm(
        id: t.id ?? 0,
        organizationId: t.organizationId,
        title: t.title,
        status: t.status.name,
        priority: t.priority.name,
        projectId: t.projectId,
        sortOrder: t.sortOrder,
        version: t.version,
      );
}
