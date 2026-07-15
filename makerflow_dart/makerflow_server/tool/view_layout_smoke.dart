// One-shot proof of the column-layout load path the Flutter UI exercises
// (fl-8-column-registry): the EXACT client.view.list call
// ServerpodViewRepository.loadTaskColumns makes, plus the JSON decode.
//   (server running on :8080, `dart bin/seed.dart` applied)
//   dart run tool/view_layout_smoke.dart
// ignore_for_file: deprecated_member_use, depend_on_referenced_packages
import 'package:makerflow_client/makerflow_client.dart';
import 'package:serverpod_client/serverpod_client.dart';

class _MemKeyManager extends AuthenticationKeyManager {
  String? _key;
  @override
  Future<String?> get() async => _key;
  @override
  Future<void> put(String key) async => _key = key;
  @override
  Future<void> remove() async => _key = null;
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
  if (!resp.success || resp.keyId == null) {
    print('FAIL: sign-in (${resp.failReason})');
    return 1;
  }
  await keys.put('${resp.keyId}:${resp.key}');
  print('Signed in as userId=${resp.userInfo?.id}.');

  try {
    final views = await client.view.list(1, entityType: 'task');
    print('view.list returned ${views.length} view(s):');
    for (final v in views) {
      print('  id=${v.id} name=${v.name} columnsJson=${v.columnsJson}');
    }
  } catch (e, st) {
    print('FAIL: view.list threw: $e');
    print(st);
    return 1;
  }
  return 0;
}
