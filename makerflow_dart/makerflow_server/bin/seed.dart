import 'package:makerflow_server/server.dart';

/// Seeds a usable demo workspace into the configured database (dev convenience).
///   dart run bin/seed.dart                 # development DB
///   dart run bin/seed.dart --mode production
/// This binary is NOT in the runtime image (it's built only in the Docker build
/// stage). In a deployed container seed via `server --mode production --seed`
/// instead — see ../DEPLOY.md step 6. Both routes share [runSeed].
/// Idempotent; guarded by the default-org check in Seed.run.
Future<void> main(List<String> args) async {
  await runSeed(args);
}
