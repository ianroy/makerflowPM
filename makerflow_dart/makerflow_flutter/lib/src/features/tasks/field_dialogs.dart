import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../data/field_models.dart';
import '../../state/providers.dart';

/// Field-definition manager dialogs (fl-8-custom-fields). Creating/editing/
/// deleting definitions is workspaceAdmin+ — the server gates it; a typed
/// Forbidden surfaces here like any other error. A type change that affects
/// existing values comes back as a typed Conflict naming the count; we show
/// it and offer the confirmed retry (`coerceValues`, the Airtable pattern).

/// Create (existing == null) or edit a field definition. Returns the saved
/// definition, or null when cancelled. Invalidates the config + task
/// providers on success (values may have been coerced).
Future<FieldConfigVm?> showFieldDialog(BuildContext context, WidgetRef ref,
    {FieldConfigVm? existing}) {
  return showDialog<FieldConfigVm>(
    context: context,
    builder: (_) => _FieldDialog(existing: existing),
  );
}

/// Confirm + delete a definition. Existing task values for its key become
/// orphans, which every reader drops tolerantly (D6).
Future<bool> confirmDeleteField(
    BuildContext context, WidgetRef ref, FieldConfigVm field) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Delete field "${field.label}"?'),
      content: const Text(
          'The column disappears for everyone. Values already stored on tasks '
          'are ignored from now on.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete')),
      ],
    ),
  );
  if (ok != true) return false;
  await ref.read(fieldRepositoryProvider).delete(field.id!);
  ref.invalidate(taskFieldConfigsProvider);
  return true;
}

class _FieldDialog extends ConsumerStatefulWidget {
  const _FieldDialog({this.existing});
  final FieldConfigVm? existing;

  @override
  ConsumerState<_FieldDialog> createState() => _FieldDialogState();
}

class _FieldDialogState extends ConsumerState<_FieldDialog> {
  late final TextEditingController _label =
      TextEditingController(text: widget.existing?.label ?? '');
  final _newOption = TextEditingController();
  late String _fieldType = widget.existing?.fieldType ?? 'text';
  late final List<FieldOption> _options =
      List.of(widget.existing?.options ?? const []);
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.existing != null;
  bool get _hasOptions =>
      _fieldType == 'select' || _fieldType == 'multiSelect' || _fieldType == 'label';

  @override
  void dispose() {
    _label.dispose();
    _newOption.dispose();
    super.dispose();
  }

  void _announce(String msg) =>
      SemanticsService.sendAnnouncement(View.of(context), msg, TextDirection.ltr);

  static String _friendly(Object e) {
    final s = e.toString();
    final i = s.indexOf('message: ');
    if (i >= 0) return s.substring(i + 'message: '.length).trim();
    return 'Something went wrong. Please try again.';
  }

  void _addOption() {
    final v = _newOption.text.trim();
    if (v.isEmpty || _options.any((o) => o.value == v)) return;
    setState(() {
      _options.add(FieldOption(v,
          color: _fieldType == 'label'
              ? MndLabelColors.grid[_options.length % MndLabelColors.grid.length]
              : null));
      _newOption.clear();
    });
  }

  Future<void> _pickColor(int index) async {
    final picked = await showDialog<Color>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Color for "${_options[index].value}"'),
        children: [
          Padding(
            padding: const EdgeInsets.all(MndSpace.s12),
            child: Wrap(
              spacing: MndSpace.s8,
              runSpacing: MndSpace.s8,
              children: [
                for (final color in MndLabelColors.grid)
                  Semantics(
                    button: true,
                    label: 'Color option',
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx, color),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius:
                              BorderRadius.circular(MakerflowShape.radiusSmall),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked != null) {
      setState(() =>
          _options[index] = FieldOption(_options[index].value, color: picked));
    }
  }

  Future<void> _save({bool coerceValues = false}) async {
    final label = _label.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Field name is required.');
      return;
    }
    if (_hasOptions && _options.isEmpty) {
      setState(() => _error = 'Add at least one option.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final draft = _isEdit
          ? widget.existing!
              .copyWith(label: label, fieldType: _fieldType, options: _options)
          : FieldConfigVm(
              key: FieldConfigVm.keyFromLabel(label),
              label: label,
              fieldType: _fieldType,
              options: _hasOptions ? _options : const [],
            );
      final saved = await ref
          .read(fieldRepositoryProvider)
          .save(ref.read(activeOrgIdProvider), draft, coerceValues: coerceValues);
      ref.invalidate(taskFieldConfigsProvider);
      ref.invalidate(tasksProvider); // values may have been coerced
      _announce('${_isEdit ? 'Updated' : 'Created'} field ${saved.label}.');
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      final msg = _friendly(e);
      // The type-change warning (Airtable pattern): offer the confirmed retry.
      if (!coerceValues && msg.contains('coerceValues')) {
        if (!mounted) return;
        setState(() => _busy = false);
        final convert = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Convert existing values?'),
            content: Text(msg),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Convert')),
            ],
          ),
        );
        if (convert == true) await _save(coerceValues: true);
        return;
      }
      setState(() => _error = msg);
      _announce('Could not save field. $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    return AlertDialog(
      title: Text(_isEdit ? 'Edit field' : 'New field'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey('field-label'),
                controller: _label,
                autofocus: !_isEdit,
                enabled: !_busy,
                decoration: const InputDecoration(
                    labelText: 'Field name', hintText: 'e.g. Material'),
              ),
              const SizedBox(height: MndSpace.s16),
              DropdownButtonFormField<String>(
                key: const ValueKey('field-type'),
                isExpanded: true,
                initialValue: _fieldType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final t in FieldConfigVm.fieldTypes)
                    DropdownMenuItem(
                        value: t, child: Text(FieldConfigVm.typeLabels[t] ?? t)),
                ],
                onChanged: _busy ? null : (v) => setState(() => _fieldType = v!),
              ),
              if (_isEdit)
                Padding(
                  padding: const EdgeInsets.only(top: MndSpace.s4),
                  child: Text('Key: ${widget.existing!.key} (fixed)',
                      style: TextStyle(fontSize: 12, color: c.muted)),
                ),
              if (_hasOptions) ...[
                const SizedBox(height: MndSpace.s16),
                Text('Options', style: TextStyle(fontSize: 12, color: c.muted)),
                for (var i = 0; i < _options.length; i++)
                  Row(children: [
                    if (_fieldType == 'label')
                      Semantics(
                        button: true,
                        label: 'Change color for ${_options[i].value}',
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: _busy ? null : () => _pickColor(i),
                          child: Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: MndSpace.s8),
                            decoration: BoxDecoration(
                              color: _options[i].color ?? MndLabelColors.blank,
                              borderRadius: BorderRadius.circular(
                                  MakerflowShape.radiusSmall),
                            ),
                          ),
                        ),
                      ),
                    Expanded(child: Text(_options[i].value)),
                    IconButton(
                      tooltip: 'Remove option ${_options[i].value}',
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close),
                      onPressed:
                          _busy ? null : () => setState(() => _options.removeAt(i)),
                    ),
                  ]),
                Row(children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('field-new-option'),
                      controller: _newOption,
                      enabled: !_busy,
                      decoration: const InputDecoration(
                          hintText: 'Add option', isDense: true),
                      onSubmitted: (_) => _addOption(),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add option',
                    icon: const Icon(Icons.add),
                    onPressed: _busy ? null : _addOption,
                  ),
                ]),
              ],
              if (_error != null) ...[
                const SizedBox(height: MndSpace.s12),
                Semantics(
                  liveRegion: true,
                  child: Text(_error!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
