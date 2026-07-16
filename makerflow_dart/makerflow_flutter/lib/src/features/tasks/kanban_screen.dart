import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../data/field_models.dart';
import '../../data/models.dart';
import '../../data/view_repository.dart';
import '../../state/providers.dart';
import '../shell/app_shell.dart';
import 'main_table_view.dart';
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

enum _TasksView { mainTable, kanban, list }

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  // Keyboard-move state: the task currently "picked up", and the candidate
  // target column index while moving.
  int? _grabbedTaskId;
  int? _targetColumn;
  _TasksView _view = _TasksView.mainTable;

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

  Future<void> _setDue(TaskVm task, DateTime due) async {
    await ref.read(taskRepositoryProvider).update(
          id: task.id,
          version: task.version,
          organizationId: task.organizationId,
          title: task.title,
          status: task.status,
          priority: task.priority,
          sortOrder: task.sortOrder,
          projectId: task.projectId,
          dueAt: due,
        );
    ref.invalidate(tasksProvider);
    _announce('Due date set for ${task.title}.');
  }

  /// Write one custom-field value (fl-8-custom-fields): merge into the task's
  /// bag and persist the whole bag (D6). Server validation failures (typed
  /// Conflict) are announced.
  Future<void> _setCustomField(TaskVm task, FieldConfigVm field, Object? value) async {
    final merged = Map<String, dynamic>.of(task.customFields);
    if (value == null) {
      merged.remove(field.key);
    } else {
      merged[field.key] = value;
    }
    try {
      await ref.read(taskRepositoryProvider).update(
            id: task.id,
            version: task.version,
            organizationId: task.organizationId,
            title: task.title,
            status: task.status,
            priority: task.priority,
            sortOrder: task.sortOrder,
            projectId: task.projectId,
            customFields: merged,
          );
      ref.invalidate(tasksProvider);
      _announce('Updated ${field.label} for ${task.title}.');
    } catch (e) {
      final s = e.toString();
      final i = s.indexOf('message: ');
      _announce('Could not update ${field.label}. '
          '${i >= 0 ? s.substring(i + 'message: '.length).trim() : 'Please try again.'}');
      ref.invalidate(tasksProvider); // drop the optimistic state
    }
  }

  Future<void> _addItem(String status, String title) async {
    await ref.read(taskRepositoryProvider).create(
          organizationId: ref.read(activeOrgIdProvider),
          title: title,
          status: status,
          priority: 'medium',
          projectId: ref.read(taskProjectFilterProvider),
        );
    ref.invalidate(tasksProvider);
    _announce('Created $title in ${_label(status)}.');
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

  String _query = '';

  // --- Saved views (fl-8-saved-views) ---

  static _TasksView _surfaceFor(String viewType) => switch (viewType) {
        'kanban' => _TasksView.kanban,
        'list' => _TasksView.list,
        _ => _TasksView.mainTable, // calendar renders as table until UI-7
      };

  static String _viewTypeOf(_TasksView v) => switch (v) {
        _TasksView.kanban => 'kanban',
        _TasksView.list => 'list',
        _TasksView.mainTable => 'table',
      };

  static String _friendly(Object e) {
    final s = e.toString();
    final i = s.indexOf('message: ');
    if (i >= 0) return s.substring(i + 'message: '.length).trim();
    return 'Something went wrong. Please try again.';
  }

  /// Select a saved view (null = back to the built-in Main table): apply its
  /// columns as LOCAL prefs + its type as the visible surface.
  void _selectSavedView(SavedViewVm? v) {
    ref.read(activeSavedViewProvider.notifier).state = v;
    ref.read(taskColumnPrefsProvider.notifier).state =
        v == null ? const [] : List.of(v.columns);
    setState(() => _view =
        v == null ? _TasksView.mainTable : _surfaceFor(v.viewType));
    _announce(v == null ? 'Main table view.' : 'View ${v.name}.');
  }

  void _selectBuiltin(_TasksView v) {
    if (ref.read(activeSavedViewProvider) != null) {
      // Leaving a saved view: drop its local column overrides too.
      ref.read(activeSavedViewProvider.notifier).state = null;
      ref.read(taskColumnPrefsProvider.notifier).state = const [];
    }
    setState(() => _view = v);
  }

  /// Current layout != the active view's saved layout (the dirty state).
  bool get _viewDirty {
    final v = ref.watch(activeSavedViewProvider);
    if (v == null) return false;
    final current = effectiveTaskColumns(ref);
    return ColumnPref.encodeList(current) != ColumnPref.encodeList(v.columns);
  }

  /// Create a view from the CURRENT layout + surface ("+" and "Save as new").
  Future<void> _addView({String? initialName}) async {
    final controller = TextEditingController(text: initialName ?? '');
    var share = false;
    final created = await showDialog<SavedViewVm>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlg) => AlertDialog(
          title: const Text('New view'),
          content: SizedBox(
            width: 320,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                key: const ValueKey('view-name'),
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'View name'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Share with the workspace'),
                value: share,
                onChanged: (v) => setDlg(() => share = v ?? false),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                try {
                  final saved =
                      await ref.read(viewRepositoryProvider).saveTaskView(
                            ref.read(activeOrgIdProvider),
                            name: name,
                            viewType: _viewTypeOf(_view),
                            columns: effectiveTaskColumns(ref, listen: false),
                            isShared: share,
                          );
                  if (ctx2.mounted) Navigator.pop(ctx2, saved);
                } catch (e) {
                  _announce('Could not save view. ${_friendly(e)}');
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (created == null) return;
    ref.invalidate(savedTaskViewsProvider);
    _selectSavedView(created);
    _announce('Created view ${created.name}.');
  }

  /// Write the current layout into the active view (the dirty-chip Save).
  Future<void> _saveActiveView() async {
    final v = ref.read(activeSavedViewProvider);
    if (v == null) return;
    try {
      final saved = await ref.read(viewRepositoryProvider).saveTaskView(
            ref.read(activeOrgIdProvider),
            id: v.id,
            name: v.name,
            viewType: v.viewType,
            columns: effectiveTaskColumns(ref, listen: false),
            isShared: v.isShared,
            version: v.version,
          );
      ref.read(activeSavedViewProvider.notifier).state = saved;
      ref.invalidate(savedTaskViewsProvider);
      _announce('Saved view ${saved.name}.');
    } catch (e) {
      _announce('Could not save view. ${_friendly(e)}');
    }
  }

  void _resetActiveView() {
    final v = ref.read(activeSavedViewProvider);
    if (v == null) return;
    ref.read(taskColumnPrefsProvider.notifier).state = List.of(v.columns);
    _announce('Reset to the saved layout of ${v.name}.');
  }

  Future<void> _onViewMenu(String action) async {
    final v = ref.read(activeSavedViewProvider);
    if (v == null) return;
    final repo = ref.read(viewRepositoryProvider);
    try {
      switch (action) {
        case 'rename':
          final controller = TextEditingController(text: v.name);
          final name = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Rename view'),
              content: TextField(
                  key: const ValueKey('view-rename'),
                  controller: controller,
                  autofocus: true),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                    child: const Text('Rename')),
              ],
            ),
          );
          if (name == null || name.isEmpty || name == v.name) return;
          final saved = await repo.saveTaskView(ref.read(activeOrgIdProvider),
              id: v.id,
              name: name,
              viewType: v.viewType,
              columns: v.columns,
              isShared: v.isShared,
              version: v.version);
          ref.read(activeSavedViewProvider.notifier).state = saved;
          _announce('Renamed view to ${saved.name}.');
        case 'duplicate':
          await _addView(initialName: '${v.name} copy');
          return; // _addView handles refresh + select
        case 'share':
          final saved = await repo.saveTaskView(ref.read(activeOrgIdProvider),
              id: v.id,
              name: v.name,
              viewType: v.viewType,
              columns: v.columns,
              isShared: !v.isShared,
              version: v.version);
          ref.read(activeSavedViewProvider.notifier).state = saved;
          _announce(saved.isShared
              ? 'View ${saved.name} is now shared with the workspace.'
              : 'View ${saved.name} is now private.');
        case 'delete':
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Delete view "${v.name}"?'),
              content: const Text('Tasks are not affected — only the view.'),
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
          if (ok != true) return;
          await repo.deleteTaskView(v.id);
          _selectSavedView(null);
          _announce('Deleted view ${v.name}.');
      }
      ref.invalidate(savedTaskViewsProvider);
    } catch (e) {
      _announce('Could not update view. ${_friendly(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    final tasksAsync = ref.watch(tasksProvider);

    // UI-2: monday board chrome — view-tabs row + toolbar row under the board
    // title. (Sticky-on-scroll + member avatars/Invite land in UI-2b.)
    return AppShell(
      routePath: '/tasks',
      title: 'Tasks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ViewTabs(
            current: _view,
            activeSaved: ref.watch(activeSavedViewProvider),
            savedViews: ref.watch(savedTaskViewsProvider).valueOrNull ?? const [],
            dirty: _viewDirty,
            onChanged: _selectBuiltin,
            onSelectSaved: _selectSavedView,
            onAddView: () => _addView(),
            onSave: _saveActiveView,
            onSaveAsNew: () => _addView(
                initialName:
                    '${ref.read(activeSavedViewProvider)?.name ?? 'My view'} copy'),
            onReset: _resetActiveView,
            onMenu: _onViewMenu,
          ),
          Divider(height: 1, color: c.line),
          _BoardToolbar(
            onNewItem: _openNewTask,
            onQuery: (q) => setState(() => _query = q),
          ),
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load: $e')),
              data: (tasks) {
                final visible = _query.isEmpty
                    ? tasks
                    : tasks
                        .where((t) =>
                            t.title.toLowerCase().contains(_query.toLowerCase()))
                        .toList();
                return switch (_view) {
                  _TasksView.mainTable => MainTableView(
                      tasks: visible,
                      onOpen: _openEditTask,
                      onSetStatus: (t, status) => _commitMove(t, status),
                      onSetDue: _setDue,
                      onAddItem: _addItem,
                      onSetCustomField: _setCustomField,
                    ),
                  _TasksView.list =>
                    _TaskListView(tasks: visible, colors: c, onEdit: _openEditTask),
                  _TasksView.kanban => _board(visible, c),
                };
              },
            ),
          ),
        ],
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

/// UI-2 + fl-8-saved-views view-tabs row: the built-in quick views (Main
/// table / Kanban / List; Calendar = announced coming-soon stub) followed by
/// the caller's SAVED VIEWS (own + shared) and a "+" that captures the
/// current layout as a new named view. The active saved view carries a menu
/// (rename / duplicate / share / delete) and — when the layout drifts from
/// its saved state — a dirty chip with Save / Save as new / Reset.
class _ViewTabs extends StatelessWidget {
  const _ViewTabs({
    required this.current,
    required this.activeSaved,
    required this.savedViews,
    required this.dirty,
    required this.onChanged,
    required this.onSelectSaved,
    required this.onAddView,
    required this.onSave,
    required this.onSaveAsNew,
    required this.onReset,
    required this.onMenu,
  });

  final _TasksView current;
  final SavedViewVm? activeSaved;
  final List<SavedViewVm> savedViews;
  final bool dirty;
  final ValueChanged<_TasksView> onChanged;
  final ValueChanged<SavedViewVm?> onSelectSaved;
  final VoidCallback onAddView;
  final VoidCallback onSave;
  final VoidCallback onSaveAsNew;
  final VoidCallback onReset;
  final ValueChanged<String> onMenu;

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;

    Widget underlined({
      required Key key,
      required String label,
      required bool active,
      required String semantics,
      VoidCallback? onTap,
      bool soon = false,
      Widget? leading,
    }) {
      return Semantics(
        key: key,
        button: !soon,
        selected: active,
        label: semantics,
        excludeSemantics: true,
        child: Tooltip(
          message: soon ? 'Coming soon' : '',
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: MndSpace.s12, vertical: MndSpace.s8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active ? c.brand : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (leading != null) ...[leading, const SizedBox(width: MndSpace.s4)],
                Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                      color: active ? c.brand : (soon ? c.muted : c.text),
                    )),
              ]),
            ),
          ),
        ),
      );
    }

    Widget builtin(String label, {_TasksView? view, bool soon = false}) =>
        underlined(
          key: ValueKey('tab:$label'),
          label: label,
          active: activeSaved == null && view != null && view == current,
          semantics: soon ? '$label view — coming soon' : '$label view',
          onTap: soon || view == null ? null : () => onChanged(view),
          soon: soon,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MndSpace.s16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          builtin('Main table', view: _TasksView.mainTable),
          builtin('Kanban', view: _TasksView.kanban),
          builtin('List', view: _TasksView.list),
          builtin('Calendar', soon: true),
          for (final v in savedViews)
            underlined(
              key: ValueKey('tab:saved:${v.id}'),
              label: v.name,
              active: activeSaved?.id == v.id,
              semantics:
                  'Saved view ${v.name}${v.isShared ? ', shared' : ''}',
              onTap: () => onSelectSaved(v),
              leading: v.isShared
                  ? Icon(Icons.people_outline, size: 14, color: c.muted)
                  : null,
            ),
          Semantics(
            key: const ValueKey('tab:add-view'),
            button: true,
            label: 'Add a view from the current layout',
            excludeSemantics: true,
            child: IconButton(
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.add),
              onPressed: onAddView,
            ),
          ),
          if (activeSaved != null)
            PopupMenuButton<String>(
              key: const ValueKey('view-menu'),
              tooltip: 'View options for ${activeSaved!.name}',
              iconSize: 18,
              onSelected: onMenu,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'rename', child: Text('Rename')),
                const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                PopupMenuItem(
                    value: 'share',
                    child: Text(activeSaved!.isShared ? 'Unshare' : 'Share')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          if (dirty) ...[
            const SizedBox(width: MndSpace.s8),
            Text('Edited', style: TextStyle(fontSize: 12, color: c.muted)),
            TextButton(
                key: const ValueKey('view-save'),
                onPressed: onSave,
                child: const Text('Save')),
            TextButton(
                key: const ValueKey('view-save-as'),
                onPressed: onSaveAsNew,
                child: const Text('Save as new')),
            TextButton(
                key: const ValueKey('view-reset'),
                onPressed: onReset,
                child: const Text('Reset')),
          ],
        ]),
      ),
    );
  }
}

/// UI-2 toolbar row: New item (primary), board search, project filter, and
/// announced coming-soon stubs for Person / Sort / Group by.
class _BoardToolbar extends ConsumerWidget {
  const _BoardToolbar({required this.onNewItem, required this.onQuery});
  final VoidCallback onNewItem;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = MakerflowTheme.of(context).colors;

    Widget stub(IconData icon, String label) => Semantics(
          label: '$label — coming soon',
          excludeSemantics: true,
          child: Tooltip(
            message: 'Coming soon',
            child: TextButton.icon(
              onPressed: null,
              icon: Icon(icon, size: 16),
              label: Text(label),
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(MndSpace.s16, MndSpace.s8, MndSpace.s16, MndSpace.s4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          MndButton(
            label: 'New item',
            icon: Icons.add,
            size: MndButtonSize.small,
            onPressed: onNewItem,
          ),
          const SizedBox(width: MndSpace.s12),
          SizedBox(
            width: 200,
            child: TextField(
              key: const ValueKey('board-search'),
              onChanged: onQuery,
              decoration: InputDecoration(
                hintText: 'Search this board',
                prefixIcon: Icon(Icons.search, size: 16, color: c.muted),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: MndSpace.s8, vertical: MndSpace.s8),
              ),
            ),
          ),
          const SizedBox(width: MndSpace.s12),
          // Project filter (null = all). Live memberships feed projectsProvider.
          ref.watch(projectsProvider).maybeWhen(
                data: (projects) => Semantics(
                  label: 'Filter tasks by project',
                  child: DropdownButton<int?>(
                    value: ref.watch(taskProjectFilterProvider),
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('All projects')),
                      for (final p in projects)
                        DropdownMenuItem<int?>(value: p.id, child: Text(p.name)),
                    ],
                    onChanged: (id) =>
                        ref.read(taskProjectFilterProvider.notifier).state = id,
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
          const SizedBox(width: MndSpace.s8),
          stub(Icons.person_outline, 'Person'),
          stub(Icons.swap_vert, 'Sort'),
          stub(Icons.layers_outlined, 'Group by'),
          // fl-8-column-registry: show/hide + keyboard reorder for Main-Table
          // columns. The popover is the non-pointer path (headers are
          // drag-only), so it lives on the always-visible toolbar.
          Builder(builder: (context) {
            final hidden =
                effectiveTaskColumns(ref).where((p) => p.hidden).length;
            return Semantics(
              label: 'Columns'
                  '${hidden > 0 ? ', $hidden hidden' : ''}. Show, hide, or reorder table columns',
              excludeSemantics: true,
              child: TextButton.icon(
                key: const ValueKey('board-columns'),
                onPressed: () => showColumnsPopover(context, ref),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: Text(hidden > 0 ? 'Columns ($hidden hidden)' : 'Columns'),
              ),
            );
          }),
        ]),
      ),
    );
  }
}
