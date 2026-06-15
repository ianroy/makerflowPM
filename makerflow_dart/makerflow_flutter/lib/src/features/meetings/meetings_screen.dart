import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';
import '../shell/app_shell.dart';

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    return AppShell(
      routePath: '/meetings',
      title: 'Meetings',
      child: AsyncList(
        value: ref.watch(meetingsProvider),
        itemBuilder: (context, m) => MfCard(
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
    );
  }

  String _statusToken(String s) => switch (s) {
        'active' => 'inProgress',
        'closed' => 'done',
        _ => 'todo',
      };
}
