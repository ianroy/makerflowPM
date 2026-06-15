import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/rbac.dart';
import '../business/channels.dart';

/// The realtime rail (fl-1-realtime-infra). A single streaming endpoint that
/// authenticates, authorizes the org, and yields the org's change stream.
/// Both the activity feed and offline sync consume this.
class RealtimeEndpoint extends Endpoint {
  Stream<ChangeEvent> subscribe(Session session, int organizationId) async* {
    // Authorize once on subscribe; the stream then stays scoped to this org.
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    yield* Channels.subscribe(session, organizationId: organizationId);
  }
}
