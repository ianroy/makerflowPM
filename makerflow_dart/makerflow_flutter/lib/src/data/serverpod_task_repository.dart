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
