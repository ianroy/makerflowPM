import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';

/// Whether to authenticate against the live Serverpod backend. Build with
/// `--dart-define=MAKERFLOW_LIVE=true`; otherwise sign-in is a local stub so
/// the UI runs with no server.
const useLiveBackend = bool.fromEnvironment('MAKERFLOW_LIVE');

/// Signed-in state. The router watches `isSignedIn`.
class SessionState {
  const SessionState({this.isSignedIn = false, this.email, this.error});
  final bool isSignedIn;
  final String? email;
  final String? error;
}

/// Sign-in / sign-out via serverpod_auth email. When live, calls
/// `client.modules.auth.email.authenticate` and stores the session key in the
/// shared [MakerflowKeyManager] so every subsequent client call is authorized
/// (proven end-to-end in makerflow_server/tool/auth_smoke.dart).
class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  /// Restore a persisted session on startup: if the key manager still holds a
  /// stored session key, treat the user as signed in (the client reuses the
  /// same key). Called once before the router is built (see main.dart) so there
  /// is no login-screen flash. Stub mode has nothing to restore.
  Future<void> restore() async {
    if (!useLiveBackend) return;
    final key = await ref.read(keyManagerProvider).get();
    if (key != null && key.isNotEmpty) {
      state = const SessionState(isSignedIn: true);
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (!useLiveBackend) {
      state = SessionState(isSignedIn: true, email: email);
      return true;
    }
    try {
      final client = ref.read(serverpodClientProvider);
      final resp = await client.modules.auth.email.authenticate(email, password);
      if (resp.success && resp.keyId != null && resp.key != null) {
        await ref.read(keyManagerProvider).put('${resp.keyId}:${resp.key}');
        state = SessionState(isSignedIn: true, email: email);
        return true;
      }
      state = SessionState(error: 'Sign-in failed: ${resp.failReason ?? 'invalid credentials'}');
      return false;
    } catch (e) {
      state = SessionState(error: 'Sign-in error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    if (useLiveBackend) {
      await ref.read(keyManagerProvider).remove();
    }
    state = const SessionState();
  }
}

final sessionProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Runs once at startup to restore a persisted session before the router is
/// built. The app gates its first frame on this (main.dart).
final sessionBootstrapProvider =
    FutureProvider<void>((ref) => ref.read(sessionProvider.notifier).restore());
