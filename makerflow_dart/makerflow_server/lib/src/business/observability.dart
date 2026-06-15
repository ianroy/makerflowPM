import 'dart:convert';
import 'package:serverpod/serverpod.dart';

/// Structured logging (Appendix I). One JSON line per logical event, with a
/// request id and the actor/org when known. NEVER log tokens, passwords, or
/// full payloads — pass only safe scalars.
class Obs {
  /// Emit a single-line JSON log via the Serverpod session logger.
  static void log(
    Session session, {
    required String event,
    String? requestId,
    int? userInfoId,
    int? organizationId,
    int? durationMs,
    Map<String, Object?> extra = const {},
  }) {
    final payload = <String, Object?>{
      'event': event,
      if (requestId != null) 'requestId': requestId,
      if (userInfoId != null) 'userId': userInfoId,
      if (organizationId != null) 'orgId': organizationId,
      if (durationMs != null) 'durationMs': durationMs,
      ...extra,
    };
    session.log(jsonEncode(_redact(payload)));
  }

  /// Defense-in-depth: drop anything that looks secret even if passed by mistake.
  static Map<String, Object?> _redact(Map<String, Object?> m) {
    const banned = {'password', 'token', 'secret', 'refreshtoken', 'authorization'};
    return {
      for (final e in m.entries)
        e.key: banned.contains(e.key.toLowerCase()) ? '[redacted]' : e.value,
    };
  }
}
