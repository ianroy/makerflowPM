import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Org-scoped realtime fan-out (Appendix C). Wraps Serverpod's messaging
/// (Redis-backed when `redis.enabled`) so a server-side mutation broadcasts a
/// [ChangeEvent] to every subscriber on that org's channel.
///
/// This is the shared rail under both the activity stream (fl-1-collab) and
/// offline sync (fl-5-offline-sync) — built once in fl-1-realtime-infra.
class Channels {
  static String orgChannel(int organizationId) => 'org:$organizationId';

  /// Publish a change to an org's channel. Call after a successful mutation.
  static Future<void> publish(
    Session session, {
    required int organizationId,
    required ChangeEvent event,
  }) async {
    session.messages.postMessage(orgChannel(organizationId), event);
  }

  /// Subscribe to an org's change stream (used inside streaming endpoints).
  /// The endpoint must authenticate + authorize the org before calling this.
  static Stream<ChangeEvent> subscribe(
    Session session, {
    required int organizationId,
  }) {
    return session.messages
        .createStream<ChangeEvent>(orgChannel(organizationId));
  }
}
