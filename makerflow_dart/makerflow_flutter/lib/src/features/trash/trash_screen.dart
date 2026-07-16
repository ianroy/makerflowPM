import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import '../shell/app_shell.dart';

/// The deleted-items queue. Restore puts a task back on the board; purge removes
/// it permanently (behind a confirm; the server requires workspace_admin+, so a
/// denied purge surfaces as a typed error). v1 covers tasks.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  void _announce(BuildContext context, String msg) =>
      SemanticsService.sendAnnouncement(View.of(context), msg, TextDirection.ltr);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    return AppShell(
      routePath: '/trash',
      title: 'Trash',
      child: AsyncList<TaskVm>(
        value: ref.watch(deletedTasksProvider),
        emptyLabel: 'Trash is empty',
        itemBuilder: (context, t) => MfCard(
          child: Row(
            children: [
              Expanded(
                child: Text(t.title,
                    style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
              ),
              TextButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(trashRepositoryProvider).restoreTask(t.id);
                    ref.invalidate(deletedTasksProvider);
                    ref.invalidate(tasksProvider);
                    if (context.mounted) _announce(context, 'Restored ${t.title}.');
                  } catch (e) {
                    if (context.mounted) _announce(context, 'Could not restore ${t.title}.');
                  }
                },
                icon: const Icon(Icons.restore),
                label: const Text('Restore'),
              ),
              IconButton(
                tooltip: 'Delete ${t.title} forever',
                icon: Icon(Icons.delete_forever, color: c.danger),
                onPressed: () => _confirmPurge(context, ref, t),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPurge(BuildContext context, WidgetRef ref, TaskVm t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete forever?'),
        content: Text('"${t.title}" will be permanently removed. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete forever')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(trashRepositoryProvider).purgeTask(t.id);
      ref.invalidate(deletedTasksProvider);
      if (context.mounted) _announce(context, 'Permanently deleted ${t.title}.');
    } catch (e) {
      if (context.mounted) {
        _announce(context, 'Could not delete ${t.title}. Requires a workspace admin.');
      }
    }
  }
}
