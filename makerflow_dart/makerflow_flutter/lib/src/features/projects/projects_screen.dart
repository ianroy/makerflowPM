import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';
import '../shell/app_shell.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    return AppShell(
      routePath: '/projects',
      title: 'Projects',
      child: AsyncList(
        value: ref.watch(projectsProvider),
        itemBuilder: (context, p) => MfCard(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
                    if (p.lane != null)
                      Text('Lane: ${p.lane}', style: TextStyle(color: c.muted, fontSize: 12)),
                  ],
                ),
              ),
              StatusBadge(status: _statusToken(p.status)),
            ],
          ),
        ),
      ),
    );
  }

  // Map project status to the shared StatusBadge vocabulary (non-color cue).
  String _statusToken(String s) => switch (s) {
        'active' => 'inProgress',
        'completed' => 'done',
        'onHold' => 'blocked',
        'archived' => 'backlog',
        _ => 'todo',
      };
}
