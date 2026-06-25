import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../data/models.dart';
import '../../state/providers.dart';
import 'new_task_dialog.dart';

/// Kanban board with TWO equally-capable move mechanisms:
///   • pointer drag-and-drop (Draggable / DragTarget) for mouse + touch, and
///   • a keyboard pattern for non-pointer users (WCAG 2.1.1 Keyboard,
///     2.5.1 Pointer Gestures): focus a card, Enter/Space to pick up, ←/→ to
///     choose a column, Enter to drop, Esc to cancel.
/// Every move is announced via a live region (WCAG 4.1.3 Status Messages).
class KanbanScreen extends ConsumerStatefulWidget {
  const KanbanScreen({super.key});
  @override
  ConsumerState<KanbanScreen> createState() => _KanbanScreenState();
}

enum _TasksView { kanban, list }

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  // Keyboard-move state: the task currently "picked up", and the candidate
  // target column index while moving.
  int? _grabbedTaskId;
  int? _targetColumn;
  _TasksView _view = _TasksView.kanban;

  void _announce(String msg) =>
      SemanticsService.sendAnnouncement(View.of(context), msg, TextDirection.ltr);

  Future<void> _commitMove(TaskVm task, String toStatus) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.move(task.id, toStatus, task.sortOrder);
    ref.invalidate(tasksProvider);
  }

  Future<void> _openNewTask() async {
    final created = await showNewTaskDialog(context);
    if (created != null) ref.invalidate(tasksProvider); // dialog announced success
  }

  Future<void> _openEditTask(TaskVm task) async {
    final updated = await showEditTaskDialog(context, task);
    if (updated != null) ref.invalidate(tasksProvider); // dialog announced success
  }

  void _onCardKey(KeyEvent e, TaskVm task, int columnIndex) {
    if (e is! KeyDownEvent) return;
    final key = e.logicalKey;

    if (_grabbedTaskId == null) {
      if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
        setState(() {
          _grabbedTaskId = task.id;
          _targetColumn = columnIndex;
        });
        _announce(
            'Picked up ${task.title}. Use left and right arrows to choose a column, Enter to drop, Escape to cancel.');
      } else if (key == LogicalKeyboardKey.keyE) {
        _openEditTask(task); // edit without entering the move flow
      }
      return;
    }

    // A task is grabbed.
    if (key == LogicalKeyboardKey.arrowLeft) {
      setState(() => _targetColumn = (_targetColumn! - 1).clamp(0, kanbanColumns.length - 1));
      _announce('Move to ${_label(kanbanColumns[_targetColumn!])}');
    } else if (key == LogicalKeyboardKey.arrowRight) {
      setState(() => _targetColumn = (_targetColumn! + 1).clamp(0, kanbanColumns.length - 1));
      _announce('Move to ${_label(kanbanColumns[_targetColumn!])}');
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      final toStatus = kanbanColumns[_targetColumn!];
      _announce('Dropped ${task.title} in ${_label(toStatus)}');
      _commitMove(task, toStatus);
      setState(() {
        _grabbedTaskId = null;
        _targetColumn = null;
      });
    } else if (key == LogicalKeyboardKey.escape) {
      _announce('Move cancelled');
      setState(() {
        _grabbedTaskId = null;
        _targetColumn = null;
      });
    }
  }

  static String _label(String status) => switch (status) {
        'inProgress' => 'In progress',
        'inReview' => 'In review',
        'todo' => 'To do',
        _ => '${status[0].toUpperCase()}${status.substring(1)}',
      };

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SegmentedButton<_TasksView>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                    value: _TasksView.kanban,
                    icon: Icon(Icons.view_kanban_outlined),
                    label: Text('Board')),
                ButtonSegment(
                    value: _TasksView.list,
                    icon: Icon(Icons.view_list_outlined),
                    label: Text('List')),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewTask,
        tooltip: 'New task',
        icon: const Icon(Icons.add),
        label: const Text('New task'),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (tasks) => _view == _TasksView.list
            ? _TaskListView(tasks: tasks, colors: c, onEdit: _openEditTask)
            : _board(tasks, c),
      ),
    );
  }

  Widget _board(List<TaskVm> tasks, MakerflowColors c) {
    final byColumn = {
      for (final col in kanbanColumns) col: tasks.where((t) => t.status == col).toList()
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var ci = 0; ci < kanbanColumns.length; ci++)
            _Column(
              status: kanbanColumns[ci],
              label: _label(kanbanColumns[ci]),
              tasks: byColumn[kanbanColumns[ci]]!,
              isMoveTarget: _grabbedTaskId != null && _targetColumn == ci,
              grabbedTaskId: _grabbedTaskId,
              colors: c,
              onAcceptDrop: (task) => _commitMove(task, kanbanColumns[ci]),
              onCardKey: (e, task) => _onCardKey(e, task, ci),
              onEdit: _openEditTask,
            ),
        ],
      ),
    );
  }
}

/// A flat, grouped-by-status list of tasks — an accessible alternative to the
/// board (WCAG 1.3.1 grouping via headers). Tapping a row opens the edit dialog.
class _TaskListView extends StatelessWidget {
  const _TaskListView({required this.tasks, required this.colors, required this.onEdit});
  final List<TaskVm> tasks;
  final MakerflowColors colors;
  final ValueChanged<TaskVm> onEdit;

  static String _label(String s) => switch (s) {
        'inProgress' => 'In progress',
        'inReview' => 'In review',
        'todo' => 'To do',
        _ => '${s[0].toUpperCase()}${s.substring(1)}',
      };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final col in kanbanColumns)
          if (tasks.any((t) => t.status == col)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4),
              child: Semantics(
                header: true,
                child: Text(_label(col),
                    style: TextStyle(color: colors.muted, fontWeight: FontWeight.w700)),
              ),
            ),
            for (final t in tasks.where((t) => t.status == col))
              Semantics(
                button: true,
                label: 'Edit ${t.title}',
                child: InkWell(
                  onTap: () => onEdit(t),
                  borderRadius: BorderRadius.circular(16),
                  child: MfCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(t.title,
                              style: TextStyle(color: colors.text, fontWeight: FontWeight.w600)),
                        ),
                        Text(t.priority, style: TextStyle(color: colors.muted, fontSize: 12)),
                        const SizedBox(width: 12),
                        StatusBadge(status: t.status),
                      ],
                    ),
                  ),
                ),
              ),
          ],
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.status,
    required this.label,
    required this.tasks,
    required this.isMoveTarget,
    required this.grabbedTaskId,
    required this.colors,
    required this.onAcceptDrop,
    required this.onCardKey,
    required this.onEdit,
  });

  final String status;
  final String label;
  final List<TaskVm> tasks;
  final bool isMoveTarget;
  final int? grabbedTaskId;
  final MakerflowColors colors;
  final ValueChanged<TaskVm> onAcceptDrop;
  final void Function(KeyEvent, TaskVm) onCardKey;
  final ValueChanged<TaskVm> onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: DragTarget<TaskVm>(
        onAcceptWithDetails: (d) => onAcceptDrop(d.data),
        builder: (context, candidate, rejected) {
          final highlight = isMoveTarget || candidate.isNotEmpty;
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.bgAccent,
              borderRadius: BorderRadius.circular(MakerflowShape.radiusCard),
              border: Border.all(
                color: highlight ? colors.focus : colors.line,
                width: highlight ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Semantics(
                    header: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontWeight: FontWeight.w700, color: colors.text)),
                        Text('${tasks.length}',
                            style: TextStyle(color: colors.muted)),
                      ],
                    ),
                  ),
                ),
                for (final task in tasks)
                  _Card(
                    task: task,
                    grabbed: grabbedTaskId == task.id,
                    onKey: (e) => onCardKey(e, task),
                    onEdit: () => onEdit(task),
                  ),
                if (tasks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('No tasks', style: TextStyle(color: colors.muted)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.task,
    required this.grabbed,
    required this.onKey,
    required this.onEdit,
  });
  final TaskVm task;
  final bool grabbed;
  final ValueChanged<KeyEvent> onKey;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    final card = Focus(
      onKeyEvent: (node, e) {
        onKey(e);
        return KeyEventResult.handled;
      },
      child: Builder(builder: (context) {
        final focused = Focus.of(context).hasFocus;
        return Semantics(
          button: true,
          label:
              '${task.title}, ${task.priority} priority${grabbed ? ', picked up' : ''}. '
              'Press Enter to ${grabbed ? 'drop' : 'pick up and move'}'
              '${grabbed ? '' : ', or E to edit'}.',
          customSemanticsActions: grabbed
              ? null
              : {const CustomSemanticsAction(label: 'Edit'): onEdit},
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(MakerflowShape.radiusControl),
              border: Border.all(
                color: grabbed
                    ? c.brand2
                    : focused
                        ? c.focus // visible keyboard focus ring (WCAG 2.4.7)
                        : c.line,
                width: (grabbed || focused) ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(status: task.status),
                    const Spacer(),
                    if (task.assigneeName != null)
                      Text(task.assigneeName!,
                          style: TextStyle(color: c.muted, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );

    // Pointer: tap to edit, drag to move (tap vs pan resolve in the gesture
    // arena, so they don't conflict). Keyboard/AT paths are independent
    // (Enter = move, E / "Edit" action = edit).
    return GestureDetector(
      onTap: onEdit,
      child: Draggable<TaskVm>(
        data: task,
        feedback:
            Opacity(opacity: 0.9, child: SizedBox(width: 260, child: card)),
        childWhenDragging: Opacity(opacity: 0.4, child: card),
        child: card,
      ),
    );
  }
}
