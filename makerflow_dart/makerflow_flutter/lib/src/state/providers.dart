import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/feature_models.dart';
import '../data/task_repository.dart';
import '../data/serverpod_task_repository.dart';
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
import '../features/_spike/a11y_spike_screen.dart';

/// Light/dark toggle (persisted to UserPreference server-side in fl-3).
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.dark);

/// The active organization id (drives every org-scoped read).
final activeOrgIdProvider = StateProvider<int>((_) => 1);

// --- Repository bindings ---
// Default to in-memory so the app runs with no server. Build with
// `--dart-define=MAKERFLOW_LIVE=true` to talk to the live Serverpod backend
// via the authenticated generated client (verified end-to-end).
final taskRepositoryProvider = Provider<TaskRepository>((ref) => useLiveBackend
    ? ServerpodTaskRepository(ref.watch(serverpodClientProvider))
    : InMemoryTaskRepository());
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

final tasksProvider = FutureProvider<List<TaskVm>>((ref) {
  final orgId = ref.watch(activeOrgIdProvider);
  return ref.watch(taskRepositoryProvider).list(orgId);
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

/// The app's primary navigation destinations (label + route + icon).
const navDestinations = <({String label, String route, IconData icon})>[
  (label: 'Dashboard', route: '/dashboard', icon: Icons.dashboard_outlined),
  (label: 'Tasks', route: '/tasks', icon: Icons.view_kanban_outlined),
  (label: 'Projects', route: '/projects', icon: Icons.folder_open_outlined),
  (label: 'Meetings', route: '/meetings', icon: Icons.event_note_outlined),
  (label: 'Equipment', route: '/equipment', icon: Icons.precision_manufacturing_outlined),
  (label: 'Consumables', route: '/consumables', icon: Icons.inventory_2_outlined),
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
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/tasks', builder: (_, __) => const KanbanScreen()),
      GoRoute(path: '/projects', builder: (_, __) => const ProjectsScreen()),
      GoRoute(path: '/equipment', builder: (_, __) => const EquipmentScreen()),
      GoRoute(path: '/consumables', builder: (_, __) => const ConsumablesScreen()),
      GoRoute(path: '/meetings', builder: (_, __) => const MeetingsScreen()),
      // fl-0-a11y-web-spike fixture. Reach at /spike for AT testing.
      GoRoute(path: '/spike', builder: (_, __) => const A11ySpikeScreen()),
    ],
  );
});
