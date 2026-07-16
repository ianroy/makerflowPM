import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/feature_models.dart';
import '../data/task_repository.dart';
import '../data/serverpod_task_repository.dart';
import 'dart:async';

import '../data/preference_repository.dart';
import '../data/field_models.dart';
import '../data/field_repository.dart';
import '../data/view_config.dart';
import '../data/view_repository.dart';
import '../data/trash_repository.dart';
import '../data/serverpod_trash_repository.dart';
import '../data/api_client.dart';
import '../data/feature_repositories.dart';
import '../data/serverpod_feature_repositories.dart';
import 'session.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/tasks/kanban_screen.dart';
import '../features/projects/projects_screen.dart';
import '../features/equipment/equipment_screen.dart';
import '../features/consumables/consumables_screen.dart';
import '../features/meetings/meetings_screen.dart';
import '../features/trash/trash_screen.dart';
import '../features/_spike/a11y_spike_screen.dart';

/// Light/dark toggle (persisted to UserPreference server-side in fl-3).
/// Light is the product default (monday-style redesign, UI-0).
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.light);

/// Sidebar collapse (UI-1); persisted via PreferenceEndpoint (fl-8).
final sidebarCollapsedProvider = StateProvider<bool>((_) => false);

// --- Per-user preference persistence (fl-8-view-field-endpoints) ---
final preferenceRepositoryProvider = Provider<PreferenceRepository>((ref) =>
    useLiveBackend
        ? ServerpodPreferenceRepository(ref.watch(serverpodClientProvider))
        : InMemoryPreferenceRepository());

/// Saved prefs, loaded once per sign-in (invalidated on sign-out). The shell
/// ref.listens to this and applies theme/sidebar when it resolves — listening
/// (not modifying) is the build-safe way to hydrate.
final prefsLoadProvider = FutureProvider<PrefsVm>(
    (ref) => ref.watch(preferenceRepositoryProvider).load());

// --- Main-Table column layout (fl-8-column-registry) ---
final viewRepositoryProvider = Provider<ViewRepository>((ref) => useLiveBackend
    ? ServerpodViewRepository(ref.watch(serverpodClientProvider))
    : InMemoryViewRepository());

/// LOCAL column edits this session (order/width/hidden). Empty = defer to the
/// saved server layout ([taskColumnLoadProvider]), then registry defaults —
/// see `effectiveTaskColumns` in main_table_view.dart. Watching the active org
/// makes an org switch reset local edits to that org's saved layout.
final taskColumnPrefsProvider = StateProvider<List<ColumnPref>>((ref) {
  ref.watch(activeOrgIdProvider);
  return const [];
});

/// Saved layout for the active org, merged in by `effectiveTaskColumns` via a
/// plain watch (derive-don't-copy — a listen-based hydration misses loads
/// that complete while the table is unmounted).
final taskColumnLoadProvider = FutureProvider<List<ColumnPref>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  return ref.watch(viewRepositoryProvider).loadTaskColumns(orgId);
});

// --- Custom-field definitions (fl-8-custom-fields, D6) ---
final fieldRepositoryProvider = Provider<FieldRepository>((ref) =>
    useLiveBackend
        ? ServerpodFieldRepository(ref.watch(serverpodClientProvider))
        : InMemoryFieldRepository());

/// The active org's task field definitions; drives the dynamic table columns
/// and the field manager. Invalidate after any definition mutation.
final taskFieldConfigsProvider = FutureProvider<List<FieldConfigVm>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  return ref.watch(fieldRepositoryProvider).listTaskFields(orgId);
});

/// The active filter/sort/group-by (fl-8-filter-sort-group). Session state
/// for the built-in quick views; applied from + saved into `filtersJson` for
/// saved views. Resets on org switch.
final taskViewConfigProvider = StateProvider<ViewConfig>((ref) {
  ref.watch(activeOrgIdProvider);
  return ViewConfig.empty;
});

// --- Saved views (fl-8-saved-views) ---
/// Named views visible to the caller (own + shared) for the active org.
/// Invalidate after any view mutation.
final savedTaskViewsProvider = FutureProvider<List<SavedViewVm>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  return ref.watch(viewRepositoryProvider).listTaskViews(orgId);
});

/// The selected saved view (null = the built-in quick views). Resets on org
/// switch. Selecting a view applies its columns as LOCAL prefs and its
/// viewType as the visible surface (kanban_screen owns that application).
final activeSavedViewProvider = StateProvider<SavedViewVm?>((ref) {
  ref.watch(activeOrgIdProvider);
  return null;
});

Timer? _columnSaveDebounce;

/// Update column prefs and persist them (debounced ~500ms per the spec, so a
/// drag-resize doesn't write on every frame).
///
/// While a SAVED VIEW is active, edits stay local (the view goes "dirty" and
/// is written only through its explicit Save flow) — they must not overwrite
/// the user's default `__table_layout`.
void setTaskColumnPrefs(WidgetRef ref, List<ColumnPref> prefs) {
  ref.read(taskColumnPrefsProvider.notifier).state = prefs;
  if (ref.read(activeSavedViewProvider) != null) return;
  final repo = ref.read(viewRepositoryProvider);
  final orgId = ref.read(activeOrgIdProvider);
  _columnSaveDebounce?.cancel();
  _columnSaveDebounce = Timer(const Duration(milliseconds: 500), () {
    // ignore: discarded_futures
    repo.saveTaskColumns(orgId, prefs).catchError((_) {});
  });
}

/// Persist the current theme + sidebar state (fire-and-forget).
void persistPrefs(WidgetRef ref) {
  final prefs = PrefsVm(
    theme: ref.read(themeModeProvider) == ThemeMode.dark ? 'dark' : 'light',
    sidebarCollapsed: ref.read(sidebarCollapsedProvider),
  );
  // ignore: discarded_futures
  ref.read(preferenceRepositoryProvider).save(prefs).catchError((_) {});
}

/// The active organization id (drives every org-scoped read).
final activeOrgIdProvider = StateProvider<int>((_) => 1);

// --- Repository bindings ---
// Default to in-memory so the app runs with no server. Build with
// `--dart-define=MAKERFLOW_LIVE=true` to talk to the live Serverpod backend
// via the authenticated generated client (verified end-to-end).
// The in-memory task store is shared between the task + trash repos (so a
// soft-delete in the stub shows up in Trash), per ProviderScope (test-isolated).
final _inMemoryTaskRepoProvider = Provider((_) => InMemoryTaskRepository());
final taskRepositoryProvider = Provider<TaskRepository>((ref) => useLiveBackend
    ? ServerpodTaskRepository(ref.watch(serverpodClientProvider))
    : ref.watch(_inMemoryTaskRepoProvider));
final trashRepositoryProvider = Provider<TrashRepository>((ref) => useLiveBackend
    ? ServerpodTrashRepository(ref.watch(serverpodClientProvider))
    : InMemoryTrashRepository(ref.watch(_inMemoryTaskRepoProvider)));
final orgRepositoryProvider = Provider<OrgRepository>((ref) => useLiveBackend
    ? ServerpodOrgRepository(ref.watch(serverpodClientProvider))
    : InMemoryOrgRepository());
final projectRepositoryProvider = Provider<ProjectRepository>((ref) => useLiveBackend
    ? ServerpodProjectRepository(ref.watch(serverpodClientProvider))
    : InMemoryProjectRepository());
final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) => useLiveBackend
    ? ServerpodEquipmentRepository(ref.watch(serverpodClientProvider))
    : InMemoryEquipmentRepository());
final consumableRepositoryProvider = Provider<ConsumableRepository>((ref) => useLiveBackend
    ? ServerpodConsumableRepository(ref.watch(serverpodClientProvider))
    : InMemoryConsumableRepository());
final meetingRepositoryProvider = Provider<MeetingRepository>((ref) => useLiveBackend
    ? ServerpodMeetingRepository(ref.watch(serverpodClientProvider))
    : InMemoryMeetingRepository());

// --- Reads, all scoped to the active org ---
final orgsProvider = FutureProvider<List<OrgVm>>((ref) => ref.watch(orgRepositoryProvider).listMine());

/// Optional project filter for the task views (null = all projects).
final taskProjectFilterProvider = StateProvider<int?>((_) => null);

final tasksProvider = FutureProvider<List<TaskVm>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  final projectId = ref.watch(taskProjectFilterProvider);
  return ref.watch(taskRepositoryProvider).list(orgId, projectId: projectId);
});
final projectsProvider = FutureProvider<List<ProjectVm>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  return ref.watch(projectRepositoryProvider).list(orgId);
});
final equipmentProvider = FutureProvider<List<EquipmentVm>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  return ref.watch(equipmentRepositoryProvider).list(orgId);
});
final consumablesProvider = FutureProvider<List<ConsumableVm>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  return ref.watch(consumableRepositoryProvider).list(orgId);
});
final meetingsProvider = FutureProvider<List<MeetingVm>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  return ref.watch(meetingRepositoryProvider).list(orgId);
});
final deletedTasksProvider = FutureProvider<List<TaskVm>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  return ref.watch(trashRepositoryProvider).deletedTasks(orgId);
});

/// The app's primary navigation destinations (label + route + icon).
const navDestinations = <({String label, String route, IconData icon})>[
  (label: 'Dashboard', route: '/dashboard', icon: Icons.dashboard_outlined),
  (label: 'Tasks', route: '/tasks', icon: Icons.view_kanban_outlined),
  (label: 'Projects', route: '/projects', icon: Icons.folder_open_outlined),
  (label: 'Meetings', route: '/meetings', icon: Icons.event_note_outlined),
  (label: 'Equipment', route: '/equipment', icon: Icons.precision_manufacturing_outlined),
  (label: 'Consumables', route: '/consumables', icon: Icons.inventory_2_outlined),
  (label: 'Trash', route: '/trash', icon: Icons.delete_outline),
];

/// go_router with an auth redirect. Feature routes render inside the app shell.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final signedIn = ref.read(sessionProvider).isSignedIn;
      final atLogin = state.matchedLocation == '/login';
      if (!signedIn && !atLogin) return '/login';
      if (signedIn && atLogin) return '/dashboard';
      return null;
    },
    routes: [
      // No page-slide transitions: monday swaps content instantly inside the
      // static shell (the slide also fought the web back/forward feel).
      GoRoute(path: '/login', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const LoginScreen())),
      GoRoute(path: '/dashboard', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const DashboardScreen())),
      GoRoute(path: '/tasks', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const KanbanScreen())),
      GoRoute(path: '/projects', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const ProjectsScreen())),
      GoRoute(path: '/equipment', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const EquipmentScreen())),
      GoRoute(path: '/consumables', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const ConsumablesScreen())),
      GoRoute(path: '/meetings', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const MeetingsScreen())),
      GoRoute(path: '/trash', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const TrashScreen())),
      // fl-0-a11y-web-spike fixture. Reach at /spike for AT testing.
      GoRoute(path: '/spike', pageBuilder: (_, s) => NoTransitionPage(key: s.pageKey, child: const A11ySpikeScreen())),
    ],
  );
});
