import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MakerFlow PM'),
        actions: [
          IconButton(
            tooltip: mode == ThemeMode.dark ? 'Switch to light' : 'Switch to dark',
            icon: Icon(mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).state =
                mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(isSignedInProvider.notifier).state = false;
              context.go('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.text)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Tile(label: 'Tasks', icon: Icons.view_kanban, onTap: () => context.go('/tasks')),
                const _Tile(label: 'Projects', icon: Icons.folder_open),
                const _Tile(label: 'Meetings', icon: Icons.event_note),
                const _Tile(label: 'Equipment', icon: Icons.precision_manufacturing),
              ],
            ),
            const SizedBox(height: 24),
            Text('Walking skeleton — Phase 0/1. See ../FLUTTER_REBUILD_PLAN.md.',
                style: TextStyle(color: c.muted)),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.icon, this.onTap});
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    return SizedBox(
      width: 160,
      height: 96,
      child: MfCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: c.brand),
            const Spacer(),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: c.text)),
          ],
        ),
      ),
    );
  }
}
