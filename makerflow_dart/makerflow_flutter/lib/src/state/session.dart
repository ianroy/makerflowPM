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
