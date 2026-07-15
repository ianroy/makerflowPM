import 'dart:convert';

import 'package:makerflow_client/makerflow_client.dart' as api;

/// Column-layout persistence for the Main Table (fl-8-column-registry).
/// One entry per visible-or-hidden column, in display order.
class ColumnPref {
  const ColumnPref({required this.key, required this.width, this.hidden = false});
  final String key;
  final double width;
  final bool hidden;

  ColumnPref copyWith({double? width, bool? hidden}) =>
      ColumnPref(key: key, width: width ?? this.width, hidden: hidden ?? this.hidden);

  Map<String, dynamic> toJson() => {'key': key, 'width': width, 'hidden': hidden};
  static ColumnPref? fromJson(Object? o) {
    if (o is! Map<String, dynamic> || o['key'] is! String) return null;
    return ColumnPref(
      key: o['key'] as String,
      width: (o['width'] as num?)?.toDouble() ?? 120,
      hidden: o['hidden'] == true,
    );
  }

  static String encodeList(List<ColumnPref> prefs) =>
      jsonEncode(prefs.map((p) => p.toJson()).toList());
  static List<ColumnPref> decodeList(String json) {
    try {
      final raw = jsonDecode(json);
      if (raw is! List) return const [];
      return raw.map(ColumnPref.fromJson).whereType<ColumnPref>().toList();
    } catch (_) {
      return const [];
    }
  }
}

/// Persists the caller's Main-Table column layout. Backed by the user's
/// implicit default `CustomView` (entityType 'task', name '__table_layout',
/// never shared) via the fl-8 ViewEndpoint; saved views proper arrive with
/// fl-8-saved-views and reuse this seam.
abstract class ViewRepository {
  Future<List<ColumnPref>> loadTaskColumns(int orgId);
  Future<void> saveTaskColumns(int orgId, List<ColumnPref> prefs);
}

class InMemoryViewRepository implements ViewRepository {
  List<ColumnPref> _prefs = const [];
  @override
  Future<List<ColumnPref>> loadTaskColumns(int orgId) async => _prefs;
  @override
  Future<void> saveTaskColumns(int orgId, List<ColumnPref> prefs) async =>
      _prefs = List.of(prefs);
}

class ServerpodViewRepository implements ViewRepository {
  ServerpodViewRepository(this._client);
  final api.Client _client;
  static const _layoutName = '__table_layout';

  Future<api.CustomView?> _findLayout(int orgId) async {
    final views = await _client.view.list(orgId, entityType: 'task');
    for (final v in views) {
      if (v.name == _layoutName) return v;
    }
    return null;
  }

  @override
  Future<List<ColumnPref>> loadTaskColumns(int orgId) async {
    final v = await _findLayout(orgId);
    return v == null ? const [] : ColumnPref.decodeList(v.columnsJson);
  }

  @override
  Future<void> saveTaskColumns(int orgId, List<ColumnPref> prefs) async {
    final now = DateTime.now().toUtc();
    final existing = await _findLayout(orgId);
    final json = ColumnPref.encodeList(prefs);
    if (existing == null) {
      await _client.view.save(api.CustomView(
        organizationId: orgId,
        ownerUserInfoId: 0, // server pins the real owner
        name: _layoutName,
        entityType: 'task',
        filtersJson: '{}',
        columnsJson: json,
        isShared: false,
        version: 1,
        createdAt: now,
        updatedAt: now,
      ));
    } else {
      await _client.view.save(existing.copyWith(columnsJson: json));
    }
  }
}
