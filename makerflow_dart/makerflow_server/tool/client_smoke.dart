import 'package:makerflow_client/makerflow_client.dart';

/// End-to-end smoke of the GENERATED client against a running server.
/// Proves the typed client + wire protocol work (not just curl).
///   (server must be running on :8080)
///   dart run tool/client_smoke.dart
Future<int> main() async {
  final client = Client('http://localhost:8080/')
    ..connectivityMonitor = null;

  // 1) Unauthenticated readiness — should round-trip true.
  final ready = await client.health.ready();
  print('health.ready -> $ready');

  // 2) An auth-gated call WITHOUT a session — should throw the typed
  //    MakerflowAuthException the server now serializes (fl-0-error-taxonomy).
  try {
    await client.task.list(1);
    print('task.list -> UNEXPECTED success (auth gate not enforced!)');
    return 1;
  } on MakerflowAuthException catch (e) {
    print('task.list -> typed MakerflowAuthException: ${e.message}  (gate OK)');
  }

  return ready ? 0 : 1;
}
