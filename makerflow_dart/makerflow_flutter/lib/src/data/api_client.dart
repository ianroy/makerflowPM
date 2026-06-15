import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_client/makerflow_client.dart' as api;
import 'package:serverpod_flutter/serverpod_flutter.dart';

/// The generated Serverpod client, verified end-to-end against the live server
/// (see makerflow_server/tool/client_smoke.dart). Host is overridable at build:
///   flutter run --dart-define=MAKERFLOW_API=https://api.makerflow.example/
final serverpodClientProvider = Provider<api.Client>((ref) {
  const host = String.fromEnvironment(
    'MAKERFLOW_API',
    defaultValue: 'http://localhost:8080/',
  );
  final client = api.Client(host)..connectivityMonitor = FlutterConnectivityMonitor();
  ref.onDispose(client.close);
  return client;
});
