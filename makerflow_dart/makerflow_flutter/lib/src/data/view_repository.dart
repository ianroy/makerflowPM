import 'dart:convert';

import 'package:makerflow_client/makerflow_client.dart' as api;

import 'view_config.dart';

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

/// A saved view (fl-8-saved-views): a named CustomView the tabs render.
/// The implicit `__table_layout` default-layout view is NOT one of these.
class SavedViewVm {
  const SavedViewVm({
    required this.id,
    required this.name,
    required this.viewType, // table | kanban | list | calendar
    required this.columns,
    this.config = ViewConfig.empty, // filter/sort/group-by (filtersJson)
    this.isShared = false,
    this.ownerUserInfoId = 0,
    this.version = 1,
  });

  final int id;
  final String name;
  final String viewType;
  final List<ColumnPref> columns;
  final ViewConfig config;
  final bool isShared;
  final int ownerUserInfoId;
  final int version;
}

/// Persists the caller's Main-Table column layout (the implicit per-user
/// `__table_layout` CustomView) AND named saved views (fl-8-saved-views),
/// both via the fl-8 ViewEndpoint.
abstract class ViewRepository {
  Future<List<ColumnPref>> loadTaskColumns(int orgId);
  Future<void> saveTaskColumns(int orgId, List<ColumnPref> prefs);

  /// Named views visible to the caller (own + shared), tab order = list order.
  Future<List<SavedViewVm>> listTaskViews(int orgId);

  /// Create (id == null) or update a named view. The server pins ownership,
  /// gates edits to owner/admin, and rejects stale versions.
  Future<SavedViewVm> saveTaskView(
    int orgId, {
    int? id,
    required String name,
    required String viewType,
    required List<ColumnPref> columns,
    ViewConfig config = ViewConfig.empty,
    bool isShared = false,
    int version = 1,
  });

  Future<void> deleteTaskView(int id);
}

class InMemoryViewRepository implements ViewRepository {
  List<ColumnPref> _prefs = const [];
  final List<SavedViewVm> _views = [];
  int _nextViewId = 1;

  @override
  Future<List<ColumnPref>> loadTaskColumns(int orgId) async => _prefs;
  @override
  Future<void> saveTaskColumns(int orgId, List<ColumnPref> prefs) async =>
      _prefs = List.of(prefs);

  @override
  Future<List<SavedViewVm>> listTaskViews(int orgId) async => List.of(_views);

  @override
  Future<SavedViewVm> saveTaskView(
    int orgId, {
    int? id,
    required String name,
    required String viewType,
    required List<ColumnPref> columns,
    ViewConfig config = ViewConfig.empty,
    bool isShared = false,
    int version = 1,
  }) async {
    final saved = SavedViewVm(
      id: id ?? _nextViewId++,
      name: name,
      viewType: viewType,
      columns: List.of(columns),
      config: config,
      isShared: isShared,
      version: version + (id == null ? 0 : 1),
    );
    final i = _views.indexWhere((v) => v.id == saved.id);
    if (i >= 0) {
      _views[i] = saved;
    } else {
      _views.add(saved);
    }
    return saved;
  }

  @override
  Future<void> deleteTaskView(int id) async =>
      _views.removeWhere((v) => v.id == id);
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

  static SavedViewVm _toVm(api.CustomView v) => SavedViewVm(
        id: v.id ?? 0,
        name: v.name,
        viewType: v.viewType,
        columns: ColumnPref.decodeList(v.columnsJson),
        config: ViewConfig.decode(v.filtersJson),
        isShared: v.isShared,
        ownerUserInfoId: v.ownerUserInfoId,
        version: v.version,
      );

  @override
  Future<List<SavedViewVm>> listTaskViews(int orgId) async {
    final views = await _client.view.list(orgId, entityType: 'task');
    return [
      for (final v in views)
        if (v.name != _layoutName) _toVm(v),
    ];
  }

  @override
  Future<SavedViewVm> saveTaskView(
    int orgId, {
    int? id,
    required String name,
    required String viewType,
    required List<ColumnPref> columns,
    ViewConfig config = ViewConfig.empty,
    bool isShared = false,
    int version = 1,
  }) async {
    final now = DateTime.now().toUtc();
    final saved = await _client.view.save(api.CustomView(
      id: id,
      organizationId: orgId,
      ownerUserInfoId: 0, // server pins/preserves the real owner
      name: name,
      entityType: 'task',
      viewType: viewType,
      filtersJson: config.encode(),
      columnsJson: ColumnPref.encodeList(columns),
      isShared: isShared,
      version: version,
      createdAt: now,
      updatedAt: now,
    ));
    return _toVm(saved);
  }

  @override
  Future<void> deleteTaskView(int id) => _client.view.softDelete(id);
}
