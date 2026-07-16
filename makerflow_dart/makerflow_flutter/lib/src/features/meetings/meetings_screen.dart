import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';
import '../inventory/feature_create_dialogs.dart';
import '../shell/app_shell.dart';

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    return AppShell(
      routePath: '/meetings',
      title: 'Meetings',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showNewMeetingDialog(context);
          if (created != null) ref.invalidate(meetingsProvider);
        },
        tooltip: 'New meeting',
        icon: const Icon(Icons.add),
        label: const Text('New meeting'),
      ),
      child: AsyncList(
        value: ref.watch(meetingsProvider),
        itemBuilder: (context, m) => Semantics(
          button: true,
          label: 'Edit ${m.title}',
          child: InkWell(
            onTap: () async {
              final updated = await showEditMeetingDialog(context, m);
              if (updated != null) ref.invalidate(meetingsProvider);
            },
            borderRadius: BorderRadius.circular(16),
            child: MfCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text(m.title, style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
                  ),
                  StatusBadge(status: _statusToken(m.status)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusToken(String s) => switch (s) {
        'active' => 'inProgress',
        'closed' => 'done',
        _ => 'todo',
      };
}
