import 'dart:convert';

import 'package:makerflow_client/makerflow_client.dart' as api;

/// Per-user preference persistence (fl-8-view-field-endpoints): theme +
/// UI layout (sidebar collapse). In-memory keeps prefs for the session;
/// the live impl round-trips PreferenceEndpoint (self-service, server-pinned).
class PrefsVm {
  const PrefsVm({this.theme = 'light', this.sidebarCollapsed = false});
  final String theme; // 'light' | 'dark'
  final bool sidebarCollapsed;

  PrefsVm copyWith({String? theme, bool? sidebarCollapsed}) => PrefsVm(
        theme: theme ?? this.theme,
        sidebarCollapsed: sidebarCollapsed ?? this.sidebarCollapsed,
      );
}

abstract class PreferenceRepository {
  Future<PrefsVm> load();
  Future<void> save(PrefsVm prefs);
}

class InMemoryPreferenceRepository implements PreferenceRepository {
  PrefsVm _prefs = const PrefsVm();
  @override
  Future<PrefsVm> load() async => _prefs;
  @override
  Future<void> save(PrefsVm prefs) async => _prefs = prefs;
}

class ServerpodPreferenceRepository implements PreferenceRepository {
  ServerpodPreferenceRepository(this._client);
  final api.Client _client;

  @override
  Future<PrefsVm> load() async {
    final p = await _client.preference.getMine();
    var collapsed = false;
    final ui = p.uiJson;
    if (ui != null && ui.isNotEmpty) {
      try {
        collapsed = (jsonDecode(ui) as Map<String, dynamic>)['sidebarCollapsed'] == true;
      } catch (_) {/* tolerate malformed prefs */}
    }
    return PrefsVm(theme: p.theme, sidebarCollapsed: collapsed);
  }

  @override
  Future<void> save(PrefsVm prefs) async {
    final existing = await _client.preference.getMine();
    await _client.preference.saveMine(existing.copyWith(
      theme: prefs.theme,
      uiJson: jsonEncode({'sidebarCollapsed': prefs.sidebarCollapsed}),
    ));
  }
}
