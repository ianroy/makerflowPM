import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'auth_context.dart';

/// Writes the append-only [AuditLog] trail. Centralized so no endpoint can
/// forget it. Call [record] inside the same transaction as the mutation.
class Audit {
  static Future<void> record(
    Session session, {
    required AuthContext ctx,
    required String entityType,
    int? entityId,
    required String action,
    Object? payload,
    String? summary,
    Transaction? transaction,
  }) async {
    final hash = payload == null
        ? null
        : sha256.convert(utf8.encode(jsonEncode(payload))).toString();

    await AuditLog.db.insertRow(
      session,
      AuditLog(
        organizationId: ctx.organizationId,
        actorUserInfoId: ctx.userInfoId,
        entityType: entityType,
        entityId: entityId,
        action: action,
        payloadHash: hash,
        summary: summary,
        createdAt: DateTime.now().toUtc(),
      ),
      transaction: transaction,
    );
  }
}
