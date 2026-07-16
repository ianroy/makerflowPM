import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';
import '../shell/app_shell.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    // Quick-jump tiles for the primary feature areas (skip Dashboard itself).
    final tiles = navDestinations.where((d) => d.route != '/dashboard').toList();
    return AppShell(
      routePath: '/dashboard',
      title: 'Home',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text('Quick access', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.text)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final d in tiles)
                  SizedBox(
                    width: 180,
                    height: 96,
                    child: MfCard(
                      onTap: () => context.go(d.route),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(d.icon, color: c.brand),
                          const Spacer(),
                          Text(d.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.w700, color: c.text)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Dashboard widgets (numbers, charts, battery) land with UI-9.',
                style: TextStyle(color: c.muted)),
          ],
        ),
      ),
    );
  }
}
