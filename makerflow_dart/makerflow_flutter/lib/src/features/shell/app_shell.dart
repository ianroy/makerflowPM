import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../state/providers.dart';
import '../../state/session.dart';

/// monday-style app shell (UI-1): everything sits on the grey app FRAME —
/// a ~48px top bar and a ~255px sidebar — with the screen content on a WHITE
/// SHEET with a rounded top-left corner. Below [_kWideBreakpoint] the sidebar
/// becomes a drawer. The old constructor API is kept so screens are untouched;
/// [actions] renders in the sheet's title row (interim home for screen
/// controls until UI-2's board chrome).
class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.routePath,
    required this.title,
    required this.child,
    this.floatingActionButton,
    this.actions = const [],
  });

  final String routePath;
  final String title;
  final Widget child;
  final Widget? floatingActionButton;
  final List<Widget> actions;

  static const _kWideBreakpoint = 900.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    final wide = MediaQuery.sizeOf(context).width >= _kWideBreakpoint;
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final showSidebar = wide && !collapsed;

    return Scaffold(
      backgroundColor: c.frame,
      floatingActionButton: floatingActionButton,
      drawer: wide
          ? null
          : Drawer(
              backgroundColor: c.frame,
              child: SafeArea(child: _Sidebar(routePath: routePath)),
            ),
      body: Column(
        children: [
          _TopBar(showMenuButton: !wide),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showSidebar) SizedBox(width: 255, child: _Sidebar(routePath: routePath)),
                if (wide) _CollapseHandle(collapsed: collapsed),
                // The white content sheet with monday's rounded top-left corner.
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(MakerflowShape.radiusNotice)),
                    child: Container(
                      color: c.bg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                MndSpace.s24, MndSpace.s16, MndSpace.s16, MndSpace.s8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Semantics(
                                    header: true,
                                    child: Text(title,
                                        style: Theme.of(context).textTheme.headlineMedium),
                                  ),
                                ),
                                ...actions,
                              ],
                            ),
                          ),
                          Expanded(
                            child: Semantics(container: true, label: title, child: child),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The ~48px top bar on the grey frame: wordmark, then search/notification
/// stubs and the avatar menu (theme switcher + sign out).
class _TopBar extends ConsumerWidget {
  const _TopBar({required this.showMenuButton});
  final bool showMenuButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    final mode = ref.watch(themeModeProvider);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: MndSpace.s12),
      color: c.frame,
      child: Row(
        children: [
          if (showMenuButton)
            Builder(
              builder: (ctx) => IconButton(
                tooltip: 'Open navigation',
                icon: const Icon(Icons.menu, size: 20),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MndSpace.s8),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: 'makerflow ',
                    style: TextStyle(
                        fontFamily: MndFonts.title,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: c.text)),
                TextSpan(
                    text: 'pm',
                    style: TextStyle(
                        fontFamily: MndFonts.title,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: c.brand)),
              ]),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Search — coming soon',
            icon: Icon(Icons.search, size: 20, color: c.muted),
            onPressed: null,
          ),
          IconButton(
            tooltip: 'Notifications — coming soon',
            icon: Icon(Icons.notifications_none, size: 20, color: c.muted),
            onPressed: null,
          ),
          const SizedBox(width: MndSpace.s4),
          PopupMenuButton<String>(
            tooltip: 'Account menu',
            offset: const Offset(0, 40),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'theme',
                child: Row(children: [
                  Icon(mode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 18),
                  const SizedBox(width: MndSpace.s8),
                  Text(mode == ThemeMode.dark ? 'Light theme' : 'Dark theme'),
                ]),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: Row(children: [
                  Icon(Icons.logout, size: 18),
                  SizedBox(width: MndSpace.s8),
                  Text('Sign out'),
                ]),
              ),
            ],
            onSelected: (v) async {
              if (v == 'theme') {
                ref.read(themeModeProvider.notifier).state =
                    mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              } else if (v == 'signout') {
                await ref.read(sessionProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(MndSpace.s4),
              child: MndAvatar(name: 'Maker Admin', size: 30),
            ),
          ),
          const SizedBox(width: MndSpace.s4),
        ],
      ),
    );
  }
}

/// The collapse/expand handle straddling the sidebar's edge.
class _CollapseHandle extends ConsumerWidget {
  const _CollapseHandle({required this.collapsed});
  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: MndSpace.s12, right: MndSpace.s4),
        child: IconButton(
          tooltip: collapsed ? 'Expand navigation' : 'Collapse navigation',
          iconSize: 16,
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            backgroundColor: c.bg,
            side: BorderSide(color: c.line),
            shape: const CircleBorder(),
          ),
          icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left, color: c.muted),
          onPressed: () =>
              ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
        ),
      ),
    );
  }
}

/// The left pane: workspace tile (org switcher), fixed destinations, then the
/// Boards section (All tasks + one board per project + the ops screens).
class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.routePath});
  final String routePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    final projectFilter = ref.watch(taskProjectFilterProvider);

    // Default the active org to the first membership when it loads (moved
    // here from the old org switcher; same ref.listen defer-out-of-build).
    ref.listen(orgsProvider, (_, next) {
      final list = next.valueOrNull;
      if (list != null &&
          list.isNotEmpty &&
          !list.any((o) => o.id == ref.read(activeOrgIdProvider))) {
        ref.read(activeOrgIdProvider.notifier).state = list.first.id;
      }
    });

    return Semantics(
      container: true,
      label: 'Primary navigation',
      explicitChildNodes: true,
      child: ListView(
        padding: const EdgeInsets.all(MndSpace.s8),
        children: [
          const _WorkspaceTile(),
          const SizedBox(height: MndSpace.s8),
          _NavRow(
            icon: Icons.home_outlined,
            label: 'Home',
            selected: routePath == '/dashboard',
            onTap: () => context.go('/dashboard'),
          ),
          const _NavRow(
            icon: Icons.check_circle_outline,
            label: 'My work',
            comingSoon: true,
          ),
          Divider(color: c.line, height: MndSpace.s16),
          const _SectionHeader('Favorites'),
          Padding(
            padding: const EdgeInsets.fromLTRB(MndSpace.s32, 0, 0, MndSpace.s8),
            child: Text('Star a board to pin it here',
                style: TextStyle(fontSize: 12, color: c.muted)),
          ),
          Divider(color: c.line, height: MndSpace.s16),
          const _SectionHeader('Boards'),
          _NavRow(
            icon: Icons.table_chart_outlined,
            label: 'All tasks',
            selected: routePath == '/tasks' && projectFilter == null,
            onTap: () {
              ref.read(taskProjectFilterProvider.notifier).state = null;
              context.go('/tasks');
            },
          ),
          // One board per project (monday: board = project).
          ...ref.watch(projectsProvider).maybeWhen(
                data: (projects) => [
                  for (final p in projects)
                    _NavRow(
                      icon: Icons.grid_view_outlined,
                      label: p.name,
                      indent: true,
                      selected: routePath == '/tasks' && projectFilter == p.id,
                      onTap: () {
                        ref.read(taskProjectFilterProvider.notifier).state = p.id;
                        context.go('/tasks');
                      },
                    ),
                ],
                orElse: () => const <Widget>[],
              ),
          _NavRow(
            icon: Icons.folder_open_outlined,
            label: 'Projects',
            selected: routePath == '/projects',
            onTap: () => context.go('/projects'),
          ),
          _NavRow(
            icon: Icons.event_note_outlined,
            label: 'Meetings',
            selected: routePath == '/meetings',
            onTap: () => context.go('/meetings'),
          ),
          _NavRow(
            icon: Icons.precision_manufacturing_outlined,
            label: 'Equipment',
            selected: routePath == '/equipment',
            onTap: () => context.go('/equipment'),
          ),
          _NavRow(
            icon: Icons.inventory_2_outlined,
            label: 'Consumables',
            selected: routePath == '/consumables',
            onTap: () => context.go('/consumables'),
          ),
          Divider(color: c.line, height: MndSpace.s16),
          _NavRow(
            icon: Icons.delete_outline,
            label: 'Trash',
            selected: routePath == '/trash',
            onTap: () => context.go('/trash'),
          ),
        ],
      ),
    );
  }
}

/// The workspace tile: colored rounded-square with the org's initial + name;
/// tapping opens the org switcher menu (live memberships).
class _WorkspaceTile extends ConsumerWidget {
  const _WorkspaceTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;
    final orgs = ref.watch(orgsProvider);
    final activeId = ref.watch(activeOrgIdProvider);

    return orgs.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(MndSpace.s8),
        child: MndSkeleton(height: 40),
      ),
      error: (e, _) => Tooltip(
        message: '$e',
        child: Padding(
          padding: const EdgeInsets.all(MndSpace.s8),
          child: Icon(Icons.error_outline, color: c.danger),
        ),
      ),
      data: (list) {
        final active = list.where((o) => o.id == activeId).firstOrNull ??
            (list.isNotEmpty ? list.first : null);
        final name = active?.name ?? 'Workspace';
        final tileColor = MndAvatar.colorFor(name);
        return PopupMenuButton<int>(
          tooltip: 'Switch workspace',
          offset: const Offset(0, 44),
          itemBuilder: (_) => [
            for (final o in list)
              PopupMenuItem(
                value: o.id,
                child: Row(children: [
                  if (o.id == activeId) const Icon(Icons.check, size: 16),
                  if (o.id == activeId) const SizedBox(width: MndSpace.s4),
                  Text(o.name),
                ]),
              ),
          ],
          onSelected: (id) => ref.read(activeOrgIdProvider.notifier).state = id,
          child: Semantics(
            button: true,
            label: 'Active workspace: $name. Switch workspace',
            child: Container(
              padding: const EdgeInsets.all(MndSpace.s8),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(MakerflowShape.radiusCard),
                border: Border.all(color: c.line),
              ),
              child: Row(children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tileColor,
                    borderRadius: BorderRadius.circular(MakerflowShape.radiusSmall),
                  ),
                  child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: MndLabelColors.textOn(tileColor))),
                ),
                const SizedBox(width: MndSpace.s8),
                Expanded(
                  child: Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                Icon(Icons.unfold_more, size: 16, color: c.muted),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(MndSpace.s8, MndSpace.s8, MndSpace.s8, MndSpace.s4),
      child: Semantics(
        header: true,
        child: Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: c.muted)),
      ),
    );
  }
}

/// One sidebar row: radius-4, `selected` fill when active, hover tint,
/// keyboard-focusable (InkWell). Coming-soon rows are disabled but announced.
class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    this.selected = false,
    this.indent = false,
    this.comingSoon = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool indent;
  final bool comingSoon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    final fg = comingSoon ? c.muted : c.text;
    return Semantics(
      button: !comingSoon,
      selected: selected,
      label: comingSoon ? '$label — coming soon' : label,
      excludeSemantics: true,
      child: Tooltip(
        message: comingSoon ? 'Coming soon' : '',
        child: InkWell(
          onTap: comingSoon ? null : onTap,
          borderRadius: BorderRadius.circular(MakerflowShape.radiusSmall),
          hoverColor: c.hover,
          child: Container(
            height: 34,
            padding: EdgeInsets.only(left: indent ? MndSpace.s24 : MndSpace.s8, right: MndSpace.s8),
            decoration: BoxDecoration(
              color: selected ? c.selected : null,
              borderRadius: BorderRadius.circular(MakerflowShape.radiusSmall),
            ),
            child: Row(children: [
              Icon(icon, size: 18, color: selected ? c.text : c.muted),
              const SizedBox(width: MndSpace.s8),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: fg)),
              ),
            ]),
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
    return value.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(MndSpace.s16),
        children: const [
          MndSkeleton(height: 56),
          SizedBox(height: MndSpace.s8),
          MndSkeleton(height: 56),
          SizedBox(height: MndSpace.s8),
          MndSkeleton(height: 56),
        ],
      ),
      error: (e, _) => Center(child: Text('Failed to load: $e')),
      data: (items) => items.isEmpty
          ? MndEmptyState(icon: Icons.inbox_outlined, headline: emptyLabel)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: MndSpace.s16, vertical: MndSpace.s8),
              itemCount: items.length,
              itemBuilder: (context, i) => itemBuilder(context, items[i]),
            ),
    );
  }
}
