import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

// Server bootstrap. Mirrors the responsibilities of the legacy Python
// `ensure_bootstrap()` + WSGI app entrypoint, but Serverpod owns routing,
// sessions, and migrations.
//
// NOTE: `src/generated/*` is produced by `serverpod generate`. Until you run
// codegen locally these imports will not resolve — that is expected for a
// freshly authored Serverpod project (see ../FLUTTER_REBUILD_PLAN.md §13,
// task fl-0-monorepo-scaffold).
Future<void> run(List<String> args) async {
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,
  );

  // Email/password auth (replaces the sessions table + PBKDF2 + CSRF).
  auth.AuthConfig.set(auth.AuthConfig(
    sendValidationEmail: (session, email, validationCode) async {
      session.log('Validation code for $email: $validationCode');
      return true; // wire to SMTP (mailer) in fl-4-io-mail
    },
    sendPasswordResetEmail: (session, userInfo, validationCode) async {
      session.log('Password reset for ${userInfo.email}: $validationCode');
      return true;
    },
  ));

  // Readiness (DB round-trip) is exposed via HealthEndpoint.ready. A bare
  // `/healthz` web route was dropped in the 2.x→3.x move (the web Route API is
  // now Relic-based); re-add as a WidgetRoute if a string liveness path is
  // needed for container health checks (follow-up: fl-0-health-route).
  await pod.start();
}
