import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../data/task_repository.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/tasks/kanban_screen.dart';
import '../features/_spike/a11y_spike_screen.dart';

/// Light/dark toggle (persisted to user prefs server-side in fl-3).
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.dark);

/// Naive auth state for the skeleton. Replaced by serverpod_auth session state
/// (SessionManager) in fl-0-auth-rbac-tenancy.
final isSignedInProvider = StateProvider<bool>((_) => false);

/// The active organization. Real org switching lands in fl-0.
final activeOrgIdProvider = StateProvider<int>((_) => 1);

/// Repository binding. Swap [InMemoryTaskRepository] for ServerpodTaskRepository
/// once the client is generated (see task_repository.dart).
final taskRepositoryProvider =
    Provider<TaskRepository>((_) => InMemoryTaskRepository());

/// Tasks for the active org.
final tasksProvider = FutureProvider<List<TaskVm>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  final orgId = ref.watch(activeOrgIdProvider);
  return repo.list(orgId);
});

/// go_router with an auth redirect.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final signedIn = ref.read(isSignedInProvider);
      final atLogin = state.matchedLocation == '/login';
      if (!signedIn && !atLogin) return '/login';
      if (signedIn && atLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/tasks', builder: (_, __) => const KanbanScreen()),
      // fl-0-a11y-web-spike fixture. Reach at /spike for AT testing.
      GoRoute(path: '/spike', builder: (_, __) => const A11ySpikeScreen()),
    ],
  );
});
