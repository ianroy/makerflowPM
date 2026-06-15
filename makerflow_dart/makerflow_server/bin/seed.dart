import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import 'package:makerflow_server/src/generated/protocol.dart';
import 'package:makerflow_server/src/generated/endpoints.dart';
import 'package:makerflow_server/src/business/seed.dart';

/// Seeds a usable demo workspace into the configured database.
///   dart bin/seed.dart            # development DB
///   dart bin/seed.dart --mode production
/// Idempotent; guarded by the default-org check in Seed.run.
Future<void> main(List<String> args) async {
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
    authenticationHandler: auth.authenticationHandler,
  );
  await pod.start();
  final session = await pod.createSession();
  try {
    await Seed.run(session);
  } finally {
    await session.close();
  }
  // CLI: terminate after seeding (the started pod would otherwise keep serving).
  await pod.shutdown(exitProcess: true);
}
