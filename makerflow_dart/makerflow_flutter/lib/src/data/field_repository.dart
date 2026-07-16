import 'package:makerflow_client/makerflow_client.dart' as api;

import 'field_models.dart';

/// Custom-field definitions for tasks (fl-8-custom-fields). The server gates
/// mutations to workspaceAdmin+ and owns validation — this seam just maps.
abstract class FieldRepository {
  Future<List<FieldConfigVm>> listTaskFields(int organizationId);

  /// Create (id == null) or update a definition. [coerceValues] confirms a
  /// type change that affects existing values (the server warns with a typed
  /// Conflict otherwise).
  Future<FieldConfigVm> save(int organizationId, FieldConfigVm draft,
      {bool coerceValues = false});

  Future<void> delete(int id);
}

class InMemoryFieldRepository implements FieldRepository {
  final List<FieldConfigVm> _fields = [];
  int _nextId = 1;

  @override
  Future<List<FieldConfigVm>> listTaskFields(int organizationId) async =>
      List.of(_fields);

  @override
  Future<FieldConfigVm> save(int organizationId, FieldConfigVm draft,
      {bool coerceValues = false}) async {
    if (draft.id == null) {
      final created = FieldConfigVm(
        id: _nextId++,
        key: draft.key,
        label: draft.label,
        fieldType: draft.fieldType,
        options: draft.options,
        required: draft.required,
      );
      _fields.add(created);
      return created;
    }
    final i = _fields.indexWhere((f) => f.id == draft.id);
    _fields[i] = draft;
    return draft;
  }

  @override
  Future<void> delete(int id) async =>
      _fields.removeWhere((f) => f.id == id);
}

class ServerpodFieldRepository implements FieldRepository {
  ServerpodFieldRepository(this._client);
  final api.Client _client;

  @override
  Future<List<FieldConfigVm>> listTaskFields(int organizationId) async {
    final rows =
        await _client.fieldConfig.list(organizationId, entityType: 'task');
    return rows
        .map((f) => FieldConfigVm(
              id: f.id,
              key: f.key,
              label: f.label,
              fieldType: f.fieldType,
              options: FieldConfigVm.decodeOptions(f.optionsJson),
              required: f.required,
            ))
        .toList();
  }

  @override
  Future<FieldConfigVm> save(int organizationId, FieldConfigVm draft,
      {bool coerceValues = false}) async {
    final now = DateTime.now().toUtc();
    final saved = await _client.fieldConfig.save(
      api.FieldConfig(
        id: draft.id,
        organizationId: organizationId,
        entityType: 'task',
        key: draft.key,
        label: draft.label,
        fieldType: draft.fieldType,
        optionsJson: draft.options.isEmpty ? null : draft.encodeOptions(),
        required: draft.required,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      ),
      coerceValues: coerceValues,
    );
    return FieldConfigVm(
      id: saved.id,
      key: saved.key,
      label: saved.label,
      fieldType: saved.fieldType,
      options: FieldConfigVm.decodeOptions(saved.optionsJson),
      required: saved.required,
    );
  }

  @override
  Future<void> delete(int id) => _client.fieldConfig.delete(id);
}
