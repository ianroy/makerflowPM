import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_client/makerflow_client.dart' as api;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

/// In-memory auth-key provider. Holds the serverpod_auth session key
/// ("keyId:key") and wraps it as a Bearer header for transport (proven against
/// the live server in makerflow_server/tool/auth_smoke.dart). Persistence
/// across launches (flutter_secure_storage) is a follow-up; in-memory keeps the
/// web build plugin-free.
// Uses AuthenticationKeyManager because the generated client constructor only
// exposes `authenticationKeyManager` (the `authKeyProvider` param isn't
// surfaced by codegen in this Serverpod version). The deprecation lints below
// are inherent to that generated API surface.
// ignore: deprecated_member_use
class MakerflowKeyManager extends AuthenticationKeyManager {
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

final keyManagerProvider = Provider<MakerflowKeyManager>((_) => MakerflowKeyManager());

/// The generated Serverpod client, authenticated via [keyManagerProvider].
/// Host overridable: flutter run --dart-define=MAKERFLOW_API=https://api.example/
final serverpodClientProvider = Provider<api.Client>((ref) {
  const host = String.fromEnvironment(
    'MAKERFLOW_API',
    defaultValue: 'http://localhost:8080/',
  );
  final client = api.Client(
    host,
    // ignore: deprecated_member_use
    authenticationKeyManager: ref.watch(keyManagerProvider),
  )..connectivityMonitor = FlutterConnectivityMonitor();
  ref.onDispose(client.close);
  return client;
});
