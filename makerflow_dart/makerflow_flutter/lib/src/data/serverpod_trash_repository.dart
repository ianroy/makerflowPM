import 'package:makerflow_client/makerflow_client.dart' as api;

import 'models.dart';
import 'trash_repository.dart';

/// Live [TrashRepository] over `client.trash.*`. Selected when the app runs
/// with `--dart-define=MAKERFLOW_LIVE=true`.
class ServerpodTrashRepository implements TrashRepository {
  ServerpodTrashRepository(this._client);
  final api.Client _client;

  @override
  Future<List<TaskVm>> deletedTasks(int orgId) async {
    final rows = await _client.trash.deletedTasks(orgId);
    return rows
        .map((t) => TaskVm(
              id: t.id ?? 0,
              organizationId: t.organizationId,
              title: t.title,
              status: t.status.name,
              priority: t.priority.name,
              projectId: t.projectId,
              sortOrder: t.sortOrder,
              version: t.version,
            ))
        .toList();
  }

  @override
  Future<void> restoreTask(int id) async => _client.trash.restoreTask(id);

  @override
  Future<void> purgeTask(int id) => _client.trash.purgeTask(id);
}
