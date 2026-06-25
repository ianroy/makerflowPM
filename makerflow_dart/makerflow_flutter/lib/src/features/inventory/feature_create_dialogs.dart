import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/feature_models.dart';
import '../../state/providers.dart';

/// Accessible "create" dialogs for the operations features (equipment,
/// consumables, meetings). Same contract as the task dialog: a Material
/// AlertDialog (focus-trap + return-focus), labelled fields, required-field
/// validation with an identified error, a busy state, and a typed-error surface
/// that announces via a live region. Each returns the created VM (so the caller
/// can refresh + the dialog announces success) or null if cancelled.

Future<EquipmentVm?> showNewEquipmentDialog(BuildContext context) =>
    showDialog<EquipmentVm>(context: context, builder: (_) => const _NewEquipmentDialog());

Future<ConsumableVm?> showNewConsumableDialog(BuildContext context) =>
    showDialog<ConsumableVm>(context: context, builder: (_) => const _NewConsumableDialog());

Future<MeetingVm?> showNewMeetingDialog(BuildContext context) =>
    showDialog<MeetingVm>(context: context, builder: (_) => const _NewMeetingDialog());

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

class _NewEquipmentDialog extends ConsumerStatefulWidget {
  const _NewEquipmentDialog();
  @override
  ConsumerState<_NewEquipmentDialog> createState() => _NewEquipmentDialogState();
}

class _NewEquipmentDialogState extends ConsumerState<_NewEquipmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _status = 'operational';
  bool _busy = false;
  String? _error;

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
      final created = await ref.read(equipmentRepositoryProvider).create(
            orgId: ref.read(activeOrgIdProvider),
            name: _name.text.trim(),
            status: _status,
          );
      if (mounted) {
        _announce(context, 'Added equipment ${created.name}.');
        Navigator.of(context).pop(created);
      }
    } catch (e) {
      final msg = _friendly(e);
      setState(() => _error = msg);
      if (mounted) _announce(context, 'Could not add equipment. $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New equipment'),
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
      actions: _actions(context, _busy, _submit),
    );
  }
}

// --- Consumable ---

class _NewConsumableDialog extends ConsumerStatefulWidget {
  const _NewConsumableDialog();
  @override
  ConsumerState<_NewConsumableDialog> createState() => _NewConsumableDialogState();
}

class _NewConsumableDialogState extends ConsumerState<_NewConsumableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _unit = TextEditingController();
  final _qty = TextEditingController(text: '0');
  final _reorder = TextEditingController(text: '0');
  bool _busy = false;
  String? _error;

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
      final created = await ref.read(consumableRepositoryProvider).create(
            orgId: ref.read(activeOrgIdProvider),
            name: _name.text.trim(),
            quantityOnHand: double.parse(_qty.text.trim()),
            reorderPoint: double.parse(_reorder.text.trim()),
            unit: _unit.text.trim().isEmpty ? null : _unit.text.trim(),
          );
      if (mounted) {
        _announce(context, 'Added consumable ${created.name}.');
        Navigator.of(context).pop(created);
      }
    } catch (e) {
      final msg = _friendly(e);
      setState(() => _error = msg);
      if (mounted) _announce(context, 'Could not add consumable. $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New consumable'),
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
      actions: _actions(context, _busy, _submit),
    );
  }
}

// --- Meeting ---

const _meetingStatuses = ['draft', 'active', 'closed'];

class _NewMeetingDialog extends ConsumerStatefulWidget {
  const _NewMeetingDialog();
  @override
  ConsumerState<_NewMeetingDialog> createState() => _NewMeetingDialogState();
}

class _NewMeetingDialogState extends ConsumerState<_NewMeetingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  String _status = 'draft';
  bool _busy = false;
  String? _error;

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
      final created = await ref.read(meetingRepositoryProvider).create(
            orgId: ref.read(activeOrgIdProvider),
            title: _title.text.trim(),
            status: _status,
          );
      if (mounted) {
        _announce(context, 'Added meeting ${created.title}.');
        Navigator.of(context).pop(created);
      }
    } catch (e) {
      final msg = _friendly(e);
      setState(() => _error = msg);
      if (mounted) _announce(context, 'Could not add meeting. $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New meeting'),
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
      actions: _actions(context, _busy, _submit),
    );
  }
}

List<Widget> _actions(BuildContext context, bool busy, VoidCallback submit) => [
      TextButton(
        onPressed: busy ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: busy ? null : submit,
        child: busy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Create'),
      ),
    ];
