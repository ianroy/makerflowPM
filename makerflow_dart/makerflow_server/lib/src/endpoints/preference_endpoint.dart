import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/auth_context.dart';

/// Per-user preferences (fl-8-view-field-endpoints): theme, locale, and UI
/// layout (`uiJson` — sidebar collapse etc.). Strictly self-service: the
/// authenticated user reads/writes only their own row (userInfoId pinned), so
/// no org-role gate applies. Not audited — user-personal settings, not org
/// data (Audit is org-scoped by design).
class PreferenceEndpoint extends Endpoint {
  /// The caller's preferences; creates defaults on first access.
  Future<UserPreference> getMine(Session session) async {
    final userInfoId = await AuthIdentity.requireUserInfoId(session);
    final existing = await UserPreference.db.findFirstRow(
      session,
      where: (p) => p.userInfoId.equals(userInfoId),
    );
    if (existing != null) return existing;
    return UserPreference.db.insertRow(
      session,
      UserPreference(
        userInfoId: userInfoId,
        theme: 'light', // the product default (monday-style redesign)
        locale: 'en',
        updatedAt: DateTime.now().toUtc(),
      ),
    );
  }

  /// Upsert the caller's preferences. userInfoId is pinned from the session —
  /// a client can never write another user's row.
  Future<UserPreference> saveMine(Session session, UserPreference draft) async {
    final userInfoId = await AuthIdentity.requireUserInfoId(session);
    final now = DateTime.now().toUtc();
    final existing = await UserPreference.db.findFirstRow(
      session,
      where: (p) => p.userInfoId.equals(userInfoId),
    );
    if (existing == null) {
      return UserPreference.db.insertRow(
          session, draft.copyWith(userInfoId: userInfoId, updatedAt: now));
    }
    return UserPreference.db.updateRow(
      session,
      draft.copyWith(id: existing.id, userInfoId: userInfoId, updatedAt: now),
    );
  }
}
