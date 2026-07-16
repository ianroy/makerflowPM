import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';
import 'src/business/seed.dart';

// Server bootstrap. Mirrors the responsibilities of the legacy Python
// `ensure_bootstrap()` + WSGI app entrypoint, but Serverpod owns routing,
// sessions, and migrations.
//
// NOTE: `src/generated/*` is produced by `serverpod generate`. Until you run
// codegen locally these imports will not resolve — that is expected for a
// freshly authored Serverpod project (see ../FLUTTER_REBUILD_PLAN.md §13,
// task fl-0-monorepo-scaffold).
Future<void> run(List<String> args) async {
  // One-off seed path: `server --mode production --seed`. An operator runs this
  // once after deploy (e.g. `doctl apps console web`) to create the first org +
  // owner. We strip `--seed` before Serverpod parses args: its ArgParser rejects
  // unknown flags and — worse — falls back to *all* defaults on a parse error,
  // which would silently drop `--mode production` and seed the dev DB instead.
  if (args.contains('--seed')) {
    await runSeed(args.where((a) => a != '--seed').toList());
    return;
  }

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

/// Seeds the configured database, then exits — **without** starting the HTTP
/// servers. The [Serverpod] constructor already starts the database pool, so a
/// session is available via [Serverpod.createSession] without [Serverpod.start];
/// this means no ports (8080–8082) are bound and it is safe to run inside an
/// already-serving container (`doctl apps console web` → `server --seed`) where
/// the monolith already holds those ports. It also skips Redis and the
/// maintenance-role auto-exit, which would otherwise race a seed mid-run.
///
/// Idempotent — a no-op if the default org already exists (guarded by
/// [Seed.run]). Reached two ways: the `--seed` flag above (production runtime
/// image) and `bin/seed.dart` (dev convenience); both share this one path.
Future<void> runSeed(List<String> args) async {
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,
  );
  final session = await pod.createSession();
  try {
    await Seed.run(session);
  } finally {
    await session.close();
  }
  // Stops the database pool and exits (no servers were started to drain).
  await pod.shutdown(exitProcess: true);
}
