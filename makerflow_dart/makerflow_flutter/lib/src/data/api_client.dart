import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:makerflow_client/makerflow_client.dart' as api;
import 'package:serverpod_client/serverpod_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

/// Auth-key manager backed by [FlutterSecureStorage] so the serverpod_auth
/// session key ("keyId:key") survives app restarts (Keychain/Keystore on
/// native, Web Crypto + localStorage on web). The key is wrapped as a Bearer
/// header for transport (proven against the live server in
/// makerflow_server/tool/auth_smoke.dart + ui_writepath_smoke.dart). An
/// in-memory cache avoids a storage read on every request.
// Uses AuthenticationKeyManager because the generated client constructor only
// exposes `authenticationKeyManager` (the `authKeyProvider` param isn't
// surfaced by codegen in this Serverpod version). The deprecation lints below
// are inherent to that generated API surface.
// ignore: deprecated_member_use
class MakerflowKeyManager extends AuthenticationKeyManager {
  MakerflowKeyManager(this._storage);
  final FlutterSecureStorage _storage;
  static const _storageKey = 'mf_session_key';
  String? _cache;

  @override
  Future<String?> get() async => _cache ??= await _storage.read(key: _storageKey);

  @override
  Future<void> put(String key) async {
    _cache = key;
    await _storage.write(key: _storageKey, value: key);
  }

  @override
  Future<void> remove() async {
    _cache = null;
    await _storage.delete(key: _storageKey);
  }

  @override
  Future<String?> toHeaderValue(String? key) async =>
      key == null ? null : wrapAsBearerAuthHeaderValue(key);
}

final keyManagerProvider = Provider<MakerflowKeyManager>(
    (_) => MakerflowKeyManager(const FlutterSecureStorage()));

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
