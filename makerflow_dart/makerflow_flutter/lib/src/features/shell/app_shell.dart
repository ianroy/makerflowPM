import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';
import '../../state/session.dart';

/// Shared chrome for authenticated screens: a navigation rail (responsive →
/// drawer below 760px), an organization switcher, theme toggle, and sign-out.
/// Built accessibly: the rail is a labelled landmark, nav items announce their
/// selected state, and the body is the `main` region.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.routePath, required this.title, required this.child});

  final String routePath;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    final mode = ref.watch(themeModeProvider);
    final wide = MediaQuery.sizeOf(context).width >= 760;
    final selectedIndex =
        navDestinations.indexWhere((d) => d.route == routePath).clamp(0, navDestinations.length - 1);

    void go(int i) => context.go(navDestinations[i].route);

    final nav = Semantics(
      label: 'Primary navigation',
      explicitChildNodes: true,
      child: NavigationRail(
        extended: wide,
        selectedIndex: selectedIndex,
        onDestinationSelected: go,
        leading: const _OrgSwitcher(),
        destinations: [
          for (final d in navDestinations)
            NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label)),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: mode == ThemeMode.dark ? 'Switch to light theme' : 'Switch to dark theme',
            icon: Icon(mode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => ref.read(themeModeProvider.notifier).state =
                mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(sessionProvider.notifier).signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      drawer: wide ? null : Drawer(child: SafeArea(child: nav)),
      body: Row(
        children: [
          if (wide) nav,
          if (wide) VerticalDivider(width: 1, color: c.line),
          // The main content region (a11y landmark).
          Expanded(child: Semantics(container: true, label: title, child: child)),
        ],
      ),
    );
  }
}

class _OrgSwitcher extends ConsumerWidget {
  const _OrgSwitcher();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    final orgs = ref.watch(orgsProvider);
    final activeId = ref.watch(activeOrgIdProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: orgs.when(
        loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Tooltip(message: '$e', child: Icon(Icons.error_outline, color: c.danger)),
        data: (list) => Semantics(
          label: 'Active workspace',
          child: DropdownButton<int>(
            value: list.any((o) => o.id == activeId) ? activeId : (list.isNotEmpty ? list.first.id : null),
            underline: const SizedBox.shrink(),
            isDense: true,
            items: [for (final o in list) DropdownMenuItem(value: o.id, child: Text(o.name))],
            onChanged: (id) {
              if (id != null) ref.read(activeOrgIdProvider.notifier).state = id;
            },
          ),
        ),
      ),
    );
  }
}

/// A simple, accessible loading/error/data scaffold for list screens.
class AsyncList<T> extends StatelessWidget {
  const AsyncList({super.key, required this.value, required this.itemBuilder, this.emptyLabel = 'Nothing here yet'});
  final AsyncValue<List<T>> value;
  final Widget Function(BuildContext, T) itemBuilder;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load: $e', style: TextStyle(color: c.danger))),
      data: (items) => items.isEmpty
          ? Center(child: Text(emptyLabel, style: TextStyle(color: c.muted)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => itemBuilder(context, items[i]),
            ),
    );
  }
}
