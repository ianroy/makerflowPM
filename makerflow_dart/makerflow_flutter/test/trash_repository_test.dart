import 'package:flutter_test/flutter_test.dart';
import 'package:makerflow_flutter/src/data/task_repository.dart';
import 'package:makerflow_flutter/src/data/trash_repository.dart';

/// The in-memory trash shares the task store, so soft-delete → trash → restore
/// coordinates (the same behavior the live path gets from the database).
void main() {
  test('soft-delete moves a task to trash; restore brings it back', () async {
    final tasks = InMemoryTaskRepository();
    final trash = InMemoryTrashRepository(tasks);

    final before = await tasks.list(1);
    final victim = before.first;

    await tasks.softDelete(victim.id);
    expect((await tasks.list(1)).length, before.length - 1);
    expect((await tasks.list(1)).any((t) => t.id == victim.id), isFalse);
    expect((await trash.deletedTasks(1)).map((t) => t.id), [victim.id]);

    await trash.restoreTask(victim.id);
    expect((await tasks.list(1)).length, before.length);
    expect((await trash.deletedTasks(1)), isEmpty);
  });

  test('purge removes a deleted task permanently', () async {
    final tasks = InMemoryTaskRepository();
    final trash = InMemoryTrashRepository(tasks);
    final victim = (await tasks.list(1)).first;

    await tasks.softDelete(victim.id);
    await trash.purgeTask(victim.id);

    expect((await trash.deletedTasks(1)), isEmpty);
    expect((await tasks.list(1)).any((t) => t.id == victim.id), isFalse);
  });
}
