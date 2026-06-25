// One-shot proof of the task write path the Flutter UI exercises, end-to-end
// over the live authenticated client. These are the EXACT client.task.* calls
// ServerpodTaskRepository.create/update/move make (the UI's repository layer),
// so this proves the full UI -> client -> HTTP -> RBAC -> Postgres path for
// writes (the widget tests prove the dialog -> repository wiring).
//   (server running on :8080, `dart bin/seed.dart` applied)
//   dart run tool/ui_writepath_smoke.dart
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

var _pass = true;
void _check(String label, bool ok, [String detail = '']) {
  print('  ${ok ? 'PASS' : 'FAIL'}: $label${detail.isEmpty ? '' : ' — $detail'}');
  if (!ok) _pass = false;
}

Future<int> main() async {
  final keys = _MemKeyManager();
  final client = Client('http://localhost:8080/', authenticationKeyManager: keys)
    ..connectivityMonitor = null;

  // Sign in as the seeded owner (same as the Flutter SessionController).
  final resp = await client.modules.auth.email
      .authenticate('admin@makerflow.local', 'ChangeMeMeow!2026');
  if (!resp.success || resp.keyId == null) {
    print('FAIL: sign-in (${resp.failReason})');
    return 1;
  }
  await keys.put('${resp.keyId}:${resp.key}');
  print('Signed in as userId=${resp.userInfo?.id}.');

  const orgId = 1;
  final now = DateTime.now().toUtc();

  // 1) Baseline list (ServerpodTaskRepository.list).
  final baseline = await client.task.list(orgId);
  _check('list returns the seeded board', baseline.length == 6,
      '${baseline.length} tasks');

  // 2) Create (ServerpodTaskRepository.create).
  final created = await client.task.create(Task(
    organizationId: orgId,
    title: 'Wire the new vinyl cutter',
    status: TaskStatus.todo,
    priority: TaskPriority.high,
    sortOrder: 0,
    version: 1,
    createdAt: now,
    updatedAt: now,
  ));
  _check('create returns a persisted task', created.id != null,
      'id=${created.id} v=${created.version}');

  final afterCreate = await client.task.list(orgId);
  _check('list reflects the create', afterCreate.length == 7,
      '${afterCreate.length} tasks');

  // 3) Edit (ServerpodTaskRepository.update) — send the base version so the
  // optimistic-concurrency check runs.
  final edited = await client.task.update(Task(
    id: created.id,
    organizationId: orgId,
    title: 'Wire the new vinyl cutter (bay 2)',
    status: created.status,
    priority: TaskPriority.urgent,
    sortOrder: created.sortOrder,
    version: created.version,
    createdAt: now,
    updatedAt: now,
  ));
  _check('update applies the edit + bumps version',
      edited.title.endsWith('(bay 2)') && edited.version == created.version + 1,
      'v=${edited.version} priority=${edited.priority.name}');

  // 4) Move (ServerpodTaskRepository.move) — kanban status change.
  final moved = await client.task.move(created.id!, TaskStatus.inProgress, 1.0);
  _check('move changes status', moved.status == TaskStatus.inProgress,
      'status=${moved.status.name}');

  // 5) Stale edit must be rejected (the conflict the edit dialog surfaces).
  try {
    await client.task.update(Task(
      id: created.id,
      organizationId: orgId,
      title: 'stale write',
      status: TaskStatus.todo,
      priority: TaskPriority.low,
      sortOrder: 0,
      version: created.version, // now stale (moved/edited since)
      createdAt: now,
      updatedAt: now,
    ));
    _check('stale update is rejected', false, 'no exception thrown');
  } on MakerflowConflictException catch (e) {
    _check('stale update -> typed MakerflowConflictException', true, e.message);
  }

  print(_pass ? '\nALL WRITE-PATH CHECKS PASSED' : '\nWRITE-PATH CHECKS FAILED');
  return _pass ? 0 : 1;
}
