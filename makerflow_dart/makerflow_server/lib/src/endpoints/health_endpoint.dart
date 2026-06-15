import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Readiness probe with a DB round-trip (legacy /readyz). The cheap liveness
/// probe (/healthz) is wired as a web route in server.dart.
class HealthEndpoint extends Endpoint {
  @override
  bool get requireLogin => false;

  Future<bool> ready(Session session) async {
    try {
      // A trivial query confirms DB connectivity.
      await Organization.db.count(session);
      return true;
    } catch (_) {
      return false;
    }
  }
}
