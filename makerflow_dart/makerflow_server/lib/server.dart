import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';
import 'src/web/routes/health_route.dart';

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

  // Cheap liveness probe (legacy /healthz). Readiness with a DB round-trip is
  // a custom endpoint — see HealthEndpoint.
  pod.webServer.addRoute(HealthRoute(), '/healthz');

  await pod.start();
}
