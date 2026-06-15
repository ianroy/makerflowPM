import 'dart:io';
import 'package:serverpod/serverpod.dart';

/// Cheap liveness probe (legacy /healthz). Does NOT touch the database, so it
/// stays green even while migrations are diagnosed (mirrors the Python app's
/// decision to keep /healthz dependency-free).
class HealthRoute extends Route {
  @override
  Future<bool> handleCall(Session session, HttpRequest request) async {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.write('{"status":"ok"}');
    await request.response.close();
    return true;
  }
}
