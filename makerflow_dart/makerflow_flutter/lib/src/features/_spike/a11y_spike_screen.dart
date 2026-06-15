import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:makerflow_design/makerflow_design.dart';

/// fl-0-a11y-web-spike — a representative Flutter **Web** slice for assistive-
/// technology testing. It deliberately exercises the four highest-risk surface
/// types from FLUTTER_REBUILD_PLAN.md §8 / Appendix F:
///
///   1. a labelled form with validation + error identification,
///   2. a keyboard-movable kanban with live-region announcements,
///   3. a modal editor with focus trap + return-focus + dialog semantics,
///   4. a data table with header semantics.
///
/// A human loads this on Flutter Web and tests with NVDA+Firefox,
/// VoiceOver+Safari, and keyboard-only, recording results in
/// docs/accessibility/flutter-web-spike-report.md. This file is the *fixture*;
/// the verdict (Flutter Web sufficient vs server-rendered fallback) is the
/// human deliverable.
class A11ySpikeScreen extends StatefulWidget {
  const A11ySpikeScreen({super.key});
  @override
  State<A11ySpikeScreen> createState() => _A11ySpikeScreenState();
}

class _A11ySpikeScreenState extends State<A11ySpikeScreen> {
  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Accessibility spike (Flutter Web)')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Test each surface with a screen reader + keyboard only. '
                'Record pass/partial/fail in docs/accessibility/flutter-web-spike-report.md.',
                style: TextStyle(color: c.muted),
              ),
              const SizedBox(height: 24),
              _Section(title: '1 · Labelled form (1.3.5 / 3.3.1 / 3.3.2 / 4.1.2)', child: const _SpikeForm()),
              const SizedBox(height: 24),
              _Section(title: '2 · Keyboard kanban + live region (2.1.1 / 2.5.1 / 4.1.3)', child: const _SpikeKanban()),
              const SizedBox(height: 24),
              _Section(title: '3 · Modal editor: focus trap + return focus (2.1.2 / 2.4.3 / 4.1.2)', child: const _SpikeModalLauncher()),
              const SizedBox(height: 24),
              _Section(title: '4 · Data table: header semantics (1.3.1)', child: const _SpikeTable()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    return MfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: c.text)),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// 1 — Form ------------------------------------------------------------------
class _SpikeForm extends StatefulWidget {
  const _SpikeForm();
  @override
  State<_SpikeForm> createState() => _SpikeFormState();
}

class _SpikeFormState extends State<_SpikeForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  String? _result;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = _formKey.currentState?.validate() ?? false;
    setState(() => _result = ok ? 'Submitted' : 'Fix the errors above');
    // Announce the outcome without moving focus (4.1.3).
    SemanticsService.announce(_result!, TextDirection.ltr);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _email,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
                labelText: 'Email', border: OutlineInputBorder(), helperText: 'Required'),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _submit, child: const Text('Submit')),
          if (_result != null) ...[
            const SizedBox(height: 8),
            Text(_result!),
          ],
        ],
      ),
    );
  }
}

// 2 — Kanban (mini, keyboard-movable) ---------------------------------------
class _SpikeKanban extends StatefulWidget {
  const _SpikeKanban();
  @override
  State<_SpikeKanban> createState() => _SpikeKanbanState();
}

class _SpikeKanbanState extends State<_SpikeKanban> {
  static const _cols = ['todo', 'inProgress', 'done'];
  String _col = 'todo';
  bool _grabbed = false;
  int _target = 0;

  void _announce(String m) => SemanticsService.announce(m, TextDirection.ltr);

  void _onKey(KeyEvent e) {
    if (e is! KeyDownEvent) return;
    final k = e.logicalKey;
    if (!_grabbed) {
      if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) {
        setState(() {
          _grabbed = true;
          _target = _cols.indexOf(_col);
        });
        _announce('Picked up card. Arrow keys to choose a column, Enter to drop, Escape to cancel.');
      }
      return;
    }
    if (k == LogicalKeyboardKey.arrowLeft) {
      setState(() => _target = (_target - 1).clamp(0, _cols.length - 1));
      _announce('Move to ${_cols[_target]}');
    } else if (k == LogicalKeyboardKey.arrowRight) {
      setState(() => _target = (_target + 1).clamp(0, _cols.length - 1));
      _announce('Move to ${_cols[_target]}');
    } else if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.space) {
      setState(() {
        _col = _cols[_target];
        _grabbed = false;
      });
      _announce('Dropped in $_col');
    } else if (k == LogicalKeyboardKey.escape) {
      setState(() => _grabbed = false);
      _announce('Move cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final col in _cols)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: c.bgAccent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _grabbed && _cols[_target] == col ? c.focus : c.line,
                    width: _grabbed && _cols[_target] == col ? 2 : 1),
              ),
              child: Column(
                children: [
                  Semantics(header: true, child: Text(col, style: TextStyle(color: c.text, fontWeight: FontWeight.w700))),
                  const SizedBox(height: 8),
                  if (_col == col)
                    Focus(
                      onKeyEvent: (_, e) {
                        _onKey(e);
                        return KeyEventResult.handled;
                      },
                      child: Builder(builder: (context) {
                        final focused = Focus.of(context).hasFocus;
                        return Semantics(
                          button: true,
                          label: 'Sample card${_grabbed ? ', picked up' : ''}. Enter to ${_grabbed ? 'drop' : 'pick up'}.',
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: c.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: _grabbed ? c.brand2 : (focused ? c.focus : c.line),
                                  width: (_grabbed || focused) ? 2 : 1),
                            ),
                            child: Text('Sample card', style: TextStyle(color: c.text)),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// 3 — Modal editor ----------------------------------------------------------
class _SpikeModalLauncher extends StatelessWidget {
  const _SpikeModalLauncher();
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          // Material's Dialog provides role=dialog + a focus scope (trap) and
          // returns focus to the launcher on dismiss. Verify both on each AT.
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(header: true, child: const Text('Edit item')),
                const SizedBox(height: 12),
                const TextField(
                  autofocus: true,
                  decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Save')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      child: const Text('Open modal editor'),
    );
  }
}

// 4 — Data table ------------------------------------------------------------
class _SpikeTable extends StatelessWidget {
  const _SpikeTable();
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Task')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Assignee')),
      ],
      rows: const [
        DataRow(cells: [DataCell(Text('Laser PM')), DataCell(Text('To do')), DataCell(Text('Sam'))]),
        DataRow(cells: [DataCell(Text('Restock plywood')), DataCell(Text('Backlog')), DataCell(Text('Jo'))]),
        DataRow(cells: [DataCell(Text('Onboard cohort')), DataCell(Text('In progress')), DataCell(Text('Pat'))]),
      ],
    );
  }
}
