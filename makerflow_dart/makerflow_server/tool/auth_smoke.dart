// One-shot proof script: uses the generated client's only exposed auth seam
// (the deprecated AuthenticationKeyManager), same rationale as
// makerflow_flutter/lib/src/data/api_client.dart. serverpod_client arrives
// transitively via makerflow_client.
// ignore_for_file: deprecated_member_use, depend_on_referenced_packages
import 'package:makerflow_client/makerflow_client.dart';
import 'package:serverpod_client/serverpod_client.dart';

/// Authenticated end-to-end smoke: sign in as the seeded owner via
/// serverpod_auth email, then call the RBAC-gated task.list and expect the 6
/// seeded tasks. Proves the full auth + session + RBAC + data path through the
/// generated client.
///   (server running on :8080, `dart bin/seed.dart` applied)
///   dart run tool/auth_smoke.dart
class _MemKeyManager extends AuthenticationKeyManager {
  String? _key;
  @override
  Future<String?> get() async => _key;
  @override
  Future<void> put(String key) async => _key = key;
  @override
  Future<void> remove() async => _key = null;
  // serverpod_auth stores "keyId:key"; the transport header must be wrapped
  // (server unwraps via unwrapAuthHeaderValue).
  @override
  Future<String?> toHeaderValue(String? key) async =>
      key == null ? null : wrapAsBearerAuthHeaderValue(key);
}

Future<int> main() async {
  final keys = _MemKeyManager();
  final client = Client('http://localhost:8080/', authenticationKeyManager: keys)
    ..connectivityMonitor = null;

  final resp = await client.modules.auth.email
      .authenticate('admin@makerflow.local', 'ChangeMeMeow!2026');
  print('authenticate -> success=${resp.success} userId=${resp.userInfo?.id}');
  if (!resp.success || resp.keyId == null || resp.key == null) {
    print('  failuremessage=${resp.failReason}');
    return 1;
  }
  await keys.put('${resp.keyId}:${resp.key}');

  final tasks = await client.task.list(1);
  print('task.list (authenticated) -> ${tasks.length} tasks');
  for (final t in tasks.take(3)) {
    print('  - ${t.title} [${t.status.name}]');
  }
  return tasks.length == 6 ? 0 : 1;
}
