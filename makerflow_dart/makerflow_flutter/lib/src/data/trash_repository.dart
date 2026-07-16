import 'models.dart';
import 'task_repository.dart';

/// The deleted-items queue (`/trash`). v1 covers tasks (the server's
/// `TrashEndpoint` does too); extend per entity as soft-delete reaches them.
/// Restore is staff+, purge is workspace_admin+ — enforced server-side, so the
/// UI surfaces the typed failure.
abstract class TrashRepository {
  Future<List<TaskVm>> deletedTasks(int orgId);
  Future<void> restoreTask(int id);
  Future<void> purgeTask(int id);
}

/// In-memory trash that shares the [InMemoryTaskRepository] instance, so a
/// soft-delete on the board shows up here (and restore puts it back) — the same
/// coordination the live path gets from the database.
class InMemoryTrashRepository implements TrashRepository {
  InMemoryTrashRepository(this._tasks);
  final InMemoryTaskRepository _tasks;

  @override
  Future<List<TaskVm>> deletedTasks(int orgId) async => _tasks.deletedFor(orgId);

  @override
  Future<void> restoreTask(int id) async => _tasks.restore(id);

  @override
  Future<void> purgeTask(int id) async => _tasks.purge(id);
}
