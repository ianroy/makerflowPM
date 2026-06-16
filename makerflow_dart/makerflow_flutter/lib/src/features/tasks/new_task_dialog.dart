import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/providers.dart';

/// Accessible "New task" dialog. Creates a task in the active org via the
/// repository (in-memory or live Serverpod). A Material [AlertDialog] gives us
/// the focus-trap + return-focus behavior (WCAG 2.4.3 / 2.1.2); fields are
/// labelled (3.3.2) and validated with identified errors (3.3.1); the typed
/// failure is surfaced inline and announced (4.1.3).
///
/// Returns the created [TaskVm] (so the caller can refresh + announce) or null
/// if cancelled.
Future<TaskVm?> showNewTaskDialog(BuildContext context) =>
    showDialog<TaskVm>(context: context, builder: (_) => const _NewTaskDialog());

const _priorities = ['low', 'medium', 'high', 'urgent'];

String _statusLabel(String s) => switch (s) {
      'inProgress' => 'In progress',
      'inReview' => 'In review',
      'todo' => 'To do',
      _ => '${s[0].toUpperCase()}${s.substring(1)}',
    };

String _cap(String s) => '${s[0].toUpperCase()}${s.substring(1)}';

class _NewTaskDialog extends ConsumerStatefulWidget {
  const _NewTaskDialog();
  @override
  ConsumerState<_NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends ConsumerState<_NewTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _status = 'todo';
  String _priority = 'medium';
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _announce(String msg) =>
      SemanticsService.sendAnnouncement(View.of(context), msg, TextDirection.ltr);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _announce('Please fix the errors in the form.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final orgId = ref.read(activeOrgIdProvider);
      final created = await ref.read(taskRepositoryProvider).create(
            organizationId: orgId,
            title: _titleController.text.trim(),
            status: _status,
            priority: _priority,
          );
      _announce('Created task ${created.title}.');
      if (mounted) Navigator.of(context).pop(created);
    } catch (e) {
      // Typed server failures (e.g. MakerflowForbiddenException) deserialize
      // here; show the message and announce it assertively.
      final msg = _friendly(e);
      setState(() => _error = msg);
      _announce('Could not create task. $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Prefer a server-provided message when present; fall back to a generic one.
  static String _friendly(Object e) {
    final s = e.toString();
    final i = s.indexOf('message: ');
    if (i >= 0) return s.substring(i + 'message: '.length).trim();
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New task'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textInputAction: TextInputAction.done,
                enabled: !_busy,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What needs doing?',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  for (final s in kanbanColumns)
                    DropdownMenuItem(value: s, child: Text(_statusLabel(s))),
                ],
                onChanged: _busy ? null : (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: [
                  for (final p in _priorities)
                    DropdownMenuItem(value: p, child: Text(_cap(p))),
                ],
                onChanged: _busy ? null : (v) => setState(() => _priority = v!),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: Theme.of(context).colorScheme.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Create'),
        ),
      ],
    );
  }
}
