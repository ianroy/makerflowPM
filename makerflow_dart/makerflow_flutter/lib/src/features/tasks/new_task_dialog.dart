import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../state/providers.dart';

/// Accessible create/edit task dialog. Writes to the active org via the
/// repository (in-memory or live Serverpod). A Material [AlertDialog] gives us
/// the focus-trap + return-focus behavior (WCAG 2.4.3 / 2.1.2); fields are
/// labelled (3.3.2) and validated with identified errors (3.3.1); the typed
/// failure — including the optimistic-concurrency conflict on edit — is
/// surfaced inline and announced (4.1.3).
///
/// Returns the written [TaskVm] (so the caller can refresh + announce) or null
/// if cancelled.
Future<TaskVm?> showNewTaskDialog(BuildContext context) =>
    showDialog<TaskVm>(context: context, builder: (_) => const _TaskDialog());

Future<TaskVm?> showEditTaskDialog(BuildContext context, TaskVm task) =>
    showDialog<TaskVm>(
        context: context, builder: (_) => _TaskDialog(existing: task));

const _priorities = ['low', 'medium', 'high', 'urgent'];

String _statusLabel(String s) => switch (s) {
      'inProgress' => 'In progress',
      'inReview' => 'In review',
      'todo' => 'To do',
      _ => '${s[0].toUpperCase()}${s.substring(1)}',
    };

String _cap(String s) => '${s[0].toUpperCase()}${s.substring(1)}';

class _TaskDialog extends ConsumerStatefulWidget {
  const _TaskDialog({this.existing});

  /// When non-null the dialog edits this task; otherwise it creates a new one.
  final TaskVm? existing;

  @override
  ConsumerState<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<_TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController =
      TextEditingController(text: widget.existing?.title ?? '');
  late String _status = widget.existing?.status ?? 'todo';
  late String _priority = widget.existing?.priority ?? 'medium';
  bool _busy = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

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
      final repo = ref.read(taskRepositoryProvider);
      final title = _titleController.text.trim();
      final TaskVm written;
      if (_isEdit) {
        final e = widget.existing!;
        written = await repo.update(
          id: e.id,
          version: e.version,
          organizationId: e.organizationId,
          title: title,
          status: _status,
          priority: _priority,
          sortOrder: e.sortOrder,
          projectId: e.projectId,
        );
      } else {
        written = await repo.create(
          organizationId: ref.read(activeOrgIdProvider),
          title: title,
          status: _status,
          priority: _priority,
        );
      }
      _announce('${_isEdit ? 'Updated' : 'Created'} task ${written.title}.');
      if (mounted) Navigator.of(context).pop(written);
    } catch (e) {
      // Typed server failures (e.g. MakerflowConflictException on a stale edit)
      // deserialize here; show the message and announce it.
      final msg = _friendly(e);
      setState(() => _error = msg);
      _announce('Could not save task. $msg');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteTask() async {
    final e = widget.existing!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('"${e.title}" will move to Trash — you can restore it there.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(taskRepositoryProvider).softDelete(e.id);
      if (mounted) {
        _announce('Deleted task ${e.title}. It is in Trash.');
        Navigator.of(context).pop(e); // non-null → caller refreshes the board
      }
    } catch (err) {
      final msg = _friendly(err);
      setState(() {
        _error = msg;
        _busy = false;
      });
      if (mounted) _announce('Could not delete task. $msg');
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
      title: Text(_isEdit ? 'Edit task' : 'New task'),
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
                isExpanded: true,
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
                isExpanded: true,
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
        if (_isEdit)
          TextButton(
            onPressed: _busy ? null : _deleteTask,
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
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
              : Text(_isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
