import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../data/models.dart';
import '../../state/providers.dart';

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

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  // Keyboard-move state: the task currently "picked up", and the candidate
  // target column index while moving.
  int? _grabbedTaskId;
  int? _targetColumn;

  void _announce(String msg) =>
      SemanticsService.sendAnnouncement(View.of(context), msg, TextDirection.ltr);

  Future<void> _commitMove(TaskVm task, String toStatus) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.move(task.id, toStatus, task.sortOrder);
    ref.invalidate(tasksProvider);
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
      appBar: AppBar(title: const Text('Tasks')),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (tasks) {
          final byColumn = {
            for (final col in kanbanColumns)
              col: tasks.where((t) => t.status == col).toList()
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
                  ),
              ],
            ),
          );
        },
      ),
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
  });

  final String status;
  final String label;
  final List<TaskVm> tasks;
  final bool isMoveTarget;
  final int? grabbedTaskId;
  final MakerflowColors colors;
  final ValueChanged<TaskVm> onAcceptDrop;
  final void Function(KeyEvent, TaskVm) onCardKey;

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
  const _Card({required this.task, required this.grabbed, required this.onKey});
  final TaskVm task;
  final bool grabbed;
  final ValueChanged<KeyEvent> onKey;

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
              'Press Enter to ${grabbed ? 'drop' : 'pick up and move'}.',
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

    // Pointer drag for mouse/touch users; keyboard path is independent.
    return Draggable<TaskVm>(
      data: task,
      feedback: Opacity(opacity: 0.9, child: SizedBox(width: 260, child: card)),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: card,
    );
  }
}
