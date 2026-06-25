import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/feature_models.dart';
import '../../state/providers.dart';

/// Accessible create/edit dialogs for the operations features (equipment,
/// consumables, meetings). Same contract as the task dialog: a Material
/// AlertDialog (focus-trap + return-focus), labelled fields, required-field
/// validation with an identified error, a busy state, and a typed-error surface
/// that announces via a live region. Each returns the written VM (so the caller
/// can refresh + the dialog announces) or null if cancelled. Pass `existing` to
/// edit; omit it to create. Live edits are non-destructive (fetch-merge in the
/// repositories), so a dialog only needs to know the fields it shows.

Future<EquipmentVm?> showNewEquipmentDialog(BuildContext context) =>
    showDialog<EquipmentVm>(context: context, builder: (_) => const _EquipmentDialog());
Future<EquipmentVm?> showEditEquipmentDialog(BuildContext context, EquipmentVm e) =>
    showDialog<EquipmentVm>(context: context, builder: (_) => _EquipmentDialog(existing: e));

Future<ConsumableVm?> showNewConsumableDialog(BuildContext context) =>
    showDialog<ConsumableVm>(context: context, builder: (_) => const _ConsumableDialog());
Future<ConsumableVm?> showEditConsumableDialog(BuildContext context, ConsumableVm c) =>
    showDialog<ConsumableVm>(context: context, builder: (_) => _ConsumableDialog(existing: c));

Future<MeetingVm?> showNewMeetingDialog(BuildContext context) =>
    showDialog<MeetingVm>(context: context, builder: (_) => const _MeetingDialog());
Future<MeetingVm?> showEditMeetingDialog(BuildContext context, MeetingVm m) =>
    showDialog<MeetingVm>(context: context, builder: (_) => _MeetingDialog(existing: m));

// --- shared helpers ---

void _announce(BuildContext context, String msg) =>
    SemanticsService.sendAnnouncement(View.of(context), msg, TextDirection.ltr);

String _friendly(Object e) {
  final s = e.toString();
  final i = s.indexOf('message: ');
  if (i >= 0) return s.substring(i + 'message: '.length).trim();
  return 'Something went wrong. Please try again.';
}

Widget _errorRow(BuildContext context, String msg) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Semantics(
        liveRegion: true,
        child: Row(children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(msg, style: TextStyle(color: Theme.of(context).colorScheme.error))),
        ]),
      ),
    );

String _cap(String s) => '${s[0].toUpperCase()}${s.substring(1)}';

List<Widget> _actions(BuildContext context, bool busy, VoidCallback submit, String label) => [
      TextButton(
        onPressed: busy ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: busy ? null : submit,
        child: busy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label),
      ),
    ];

// --- Equipment ---

const _equipmentStatuses = [
  'operational',
  'maintenanceDue',
  'underMaintenance',
  'outOfService',
  'retired',
];

String _equipmentStatusLabel(String s) => switch (s) {
      'maintenanceDue' => 'Maintenance due',
      'underMaintenance' => 'Under maintenance',
      'outOfService' => 'Out of service',
      _ => _cap(s),
    };

class _EquipmentDialog extends ConsumerStatefulWidget {
  const _EquipmentDialog({this.existing});
  final EquipmentVm? existing;
  @override
  ConsumerState<_EquipmentDialog> createState() => _EquipmentDialogState();
}

class _EquipmentDialogState extends ConsumerState<_EquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late String _status = widget.existing?.status ?? 'operational';
  bool _busy = false;
  String? _error;
  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(equipmentRepositoryProvider);
      final orgId = ref.read(activeOrgIdProvider);
      final saved = _isEdit
          ? await repo.update(id: widget.existing!.id, orgId: orgId, name: _name.text.trim(), status: _status)
          : await repo.create(orgId: orgId, name: _name.text.trim(), status: _status);
      if (mounted) {
        _announce(context, '${_isEdit ? 'Updated' : 'Added'} equipment ${saved.name}.');
        Navigator.of(context).pop(saved);
      }
    } catch (e) {
      final msg = _friendly(e);
      setState(() => _error = msg);
      if (mounted) _announce(context, 'Could not save equipment. $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit equipment' : 'New equipment'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 380,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              enabled: !_busy,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                for (final s in _equipmentStatuses)
                  DropdownMenuItem(value: s, child: Text(_equipmentStatusLabel(s))),
              ],
              onChanged: _busy ? null : (v) => setState(() => _status = v!),
            ),
            if (_error != null) _errorRow(context, _error!),
          ]),
        ),
      ),
      actions: _actions(context, _busy, _submit, _isEdit ? 'Save' : 'Create'),
    );
  }
}

// --- Consumable ---

class _ConsumableDialog extends ConsumerStatefulWidget {
  const _ConsumableDialog({this.existing});
  final ConsumableVm? existing;
  @override
  ConsumerState<_ConsumableDialog> createState() => _ConsumableDialogState();
}

class _ConsumableDialogState extends ConsumerState<_ConsumableDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _unit = TextEditingController(text: widget.existing?.unit ?? '');
  late final _qty =
      TextEditingController(text: (widget.existing?.quantityOnHand ?? 0).toStringAsFixed(0));
  late final _reorder =
      TextEditingController(text: (widget.existing?.reorderPoint ?? 0).toStringAsFixed(0));
  bool _busy = false;
  String? _error;
  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _qty.dispose();
    _reorder.dispose();
    super.dispose();
  }

  String? _number(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return double.tryParse(v.trim()) == null ? 'Must be a number' : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(consumableRepositoryProvider);
      final orgId = ref.read(activeOrgIdProvider);
      final unit = _unit.text.trim().isEmpty ? null : _unit.text.trim();
      final saved = _isEdit
          ? await repo.update(
              id: widget.existing!.id,
              orgId: orgId,
              name: _name.text.trim(),
              quantityOnHand: double.parse(_qty.text.trim()),
              reorderPoint: double.parse(_reorder.text.trim()),
              unit: unit)
          : await repo.create(
              orgId: orgId,
              name: _name.text.trim(),
              quantityOnHand: double.parse(_qty.text.trim()),
              reorderPoint: double.parse(_reorder.text.trim()),
              unit: unit);
      if (mounted) {
        _announce(context, '${_isEdit ? 'Updated' : 'Added'} consumable ${saved.name}.');
        Navigator.of(context).pop(saved);
      }
    } catch (e) {
      final msg = _friendly(e);
      setState(() => _error = msg);
      if (mounted) _announce(context, 'Could not save consumable. $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit consumable' : 'New consumable'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 380,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _name,
              autofocus: true,
              enabled: !_busy,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _qty,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity on hand'),
                  validator: _number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _reorder,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Reorder at'),
                  validator: _number,
                ),
              ),
            ]),
            const SizedBox(height: 16),
            TextFormField(
              controller: _unit,
              enabled: !_busy,
              decoration: const InputDecoration(labelText: 'Unit (optional)', hintText: 'sheets, spools…'),
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_error != null) _errorRow(context, _error!),
          ]),
        ),
      ),
      actions: _actions(context, _busy, _submit, _isEdit ? 'Save' : 'Create'),
    );
  }
}

// --- Meeting ---

const _meetingStatuses = ['draft', 'active', 'closed'];

class _MeetingDialog extends ConsumerStatefulWidget {
  const _MeetingDialog({this.existing});
  final MeetingVm? existing;
  @override
  ConsumerState<_MeetingDialog> createState() => _MeetingDialogState();
}

class _MeetingDialogState extends ConsumerState<_MeetingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late String _status = widget.existing?.status ?? 'draft';
  bool _busy = false;
  String? _error;
  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final repo = ref.read(meetingRepositoryProvider);
      final orgId = ref.read(activeOrgIdProvider);
      final saved = _isEdit
          ? await repo.update(id: widget.existing!.id, orgId: orgId, title: _title.text.trim(), status: _status)
          : await repo.create(orgId: orgId, title: _title.text.trim(), status: _status);
      if (mounted) {
        _announce(context, '${_isEdit ? 'Updated' : 'Added'} meeting ${saved.title}.');
        Navigator.of(context).pop(saved);
      }
    } catch (e) {
      final msg = _friendly(e);
      setState(() => _error = msg);
      if (mounted) _announce(context, 'Could not save meeting. $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? 'Edit meeting' : 'New meeting'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 380,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _title,
              autofocus: true,
              enabled: !_busy,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                for (final s in _meetingStatuses)
                  DropdownMenuItem(value: s, child: Text(_cap(s))),
              ],
              onChanged: _busy ? null : (v) => setState(() => _status = v!),
            ),
            if (_error != null) _errorRow(context, _error!),
          ]),
        ),
      ),
      actions: _actions(context, _busy, _submit, _isEdit ? 'Save' : 'Create'),
    );
  }
}
