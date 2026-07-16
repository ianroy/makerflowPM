import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../data/field_models.dart';
import '../../data/models.dart';
import '../../data/view_repository.dart';
import '../../state/providers.dart';
import 'custom_field_cells.dart';
import 'field_dialogs.dart';

/// UI-3 + fl-8: monday's signature **Main Table** view with a column SYSTEM —
/// built-in columns AND custom fields (fl-8-custom-fields) are specs in one
/// registry, rendered in a per-user order with per-user widths, resizable
/// (drag the header boundary; double-tap = autofit), reorderable (drag a
/// header; the item-name column is pinned first), and hideable (the Columns
/// popover — also the keyboard/AT path for reorder AND the field manager).
/// Layout persists via [setTaskColumnPrefs] (debounced) into the user's
/// default CustomView; custom-field VALUES write through [MainTableView.onSetCustomField].
///
/// A11y: group titles are semantic headers; every cell action is a focusable
/// button; the popover provides non-pointer equivalents for hide + reorder.
class MainTableView extends ConsumerStatefulWidget {
  const MainTableView({
    super.key,
    required this.tasks,
    required this.onOpen,
    required this.onSetStatus,
    required this.onSetDue,
    required this.onAddItem,
    required this.onSetCustomField,
  });

  final List<TaskVm> tasks;
  final ValueChanged<TaskVm> onOpen;
  final void Function(TaskVm task, String status) onSetStatus;
  final void Function(TaskVm task, DateTime due) onSetDue;
  final void Function(String status, String title) onAddItem;

  /// Write one custom-field value (null clears). The owner merges into the
  /// task's bag and persists (D6 whole-bag replace).
  final void Function(TaskVm task, FieldConfigVm field, Object? value)
      onSetCustomField;

  @override
  ConsumerState<MainTableView> createState() => _MainTableViewState();
}

/// The columns to render, in order: the user's LOCAL edits when they've
/// touched the layout this session, else the saved server layout once it
/// loads, else registry defaults — always merged over the registry (built-ins
/// + the org's custom fields).
///
/// This is a pure derivation (`ref.watch` on all sources), NOT a listen-and-
/// copy: a `ref.listen` hydration misses loads that complete while the table
/// is unmounted (e.g. swapped for the tasks spinner), because listen only
/// fires on transitions. Watching rebuilds whenever any source lands.
List<ColumnPref> effectiveTaskColumns(WidgetRef ref) {
  final registry = _MainTableViewState.registryWith(
      ref.watch(taskFieldConfigsProvider).valueOrNull ?? const []);
  final local = ref.watch(taskColumnPrefsProvider);
  if (local.isNotEmpty) {
    return _MainTableViewState.effectivePrefs(local, registry);
  }
  final loaded = ref.watch(taskColumnLoadProvider).valueOrNull ?? const [];
  return _MainTableViewState.effectivePrefs(loaded, registry);
}

/// One column the table knows how to render. The registry is the single
/// source; user prefs (order/width/hidden) overlay it.
class _TaskColumnSpec {
  const _TaskColumnSpec({
    required this.key,
    required this.label,
    required this.defaultWidth,
    required this.minWidth,
    required this.textOf,
    required this.cellBuilder,
    this.field,
  });

  final String key;
  final String label;
  final double defaultWidth;
  final double minWidth;

  /// Non-null when this column renders a custom field (fl-8-custom-fields).
  final FieldConfigVm? field;

  /// Plain-text value of a cell — powers double-tap autofit (and sorting later).
  final String Function(TaskVm) textOf;
  final Widget Function(BuildContext, TaskVm, _MainTableViewState) cellBuilder;

  static const maxWidth = 420.0;
}

class _MainTableViewState extends ConsumerState<MainTableView> {
  final Set<String> _collapsed = {};

  static String _label(String s) => StatusLabel.labels[s] ?? s;

  static String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  /// Built-in columns (item-name is pinned/flexible and lives outside the
  /// registry). Custom fields are appended by [registryWith].
  static final List<_TaskColumnSpec> builtins = [
    _TaskColumnSpec(
      key: 'status',
      label: 'Status',
      defaultWidth: 150,
      minWidth: 90,
      textOf: (t) => _label(t.status),
      cellBuilder: (context, t, s) => StatusLabel.cell(
          status: t.status, onTap: () => s._pickStatus(context, t)),
    ),
    _TaskColumnSpec(
      key: 'due',
      label: 'Due date',
      defaultWidth: 104,
      minWidth: 80,
      textOf: (t) => t.dueAt == null ? '—' : _fmtDate(t.dueAt!),
      cellBuilder: (context, t, s) => s._dueCell(context, t),
    ),
    _TaskColumnSpec(
      key: 'priority',
      label: 'Priority',
      defaultWidth: 92,
      minWidth: 60,
      textOf: (t) => t.priority,
      cellBuilder: (context, t, s) => Center(
        child: Text(t.priority,
            style: TextStyle(
                fontSize: 13, color: MakerflowTheme.of(context).colors.muted)),
      ),
    ),
  ];

  static const _fieldTypeWidths = <String, double>{
    'text': 140, 'longText': 180, 'number': 100, 'date': 104, 'select': 120,
    'multiSelect': 160, 'person': 110, 'checkbox': 80, 'label': 140,
  };

  /// Custom-field column keys are prefixed so a field named "status" can
  /// never collide with a built-in column key inside saved layouts.
  static String fieldColumnKey(String fieldKey) => 'cf:$fieldKey';

  static _TaskColumnSpec _fieldSpec(FieldConfigVm f) => _TaskColumnSpec(
        key: fieldColumnKey(f.key),
        label: f.label,
        defaultWidth: _fieldTypeWidths[f.fieldType] ?? 130,
        minWidth: 70,
        field: f,
        textOf: (t) => customFieldText(f, t.customFields[f.key]),
        cellBuilder: (context, t, s) => customFieldCell(
          context,
          f,
          t.customFields[f.key],
          taskTitle: t.title,
          onSet: (v) => s.widget.onSetCustomField(t, f, v),
        ),
      );

  /// The full registry: built-ins + one column per custom-field definition.
  static List<_TaskColumnSpec> registryWith(List<FieldConfigVm> fields) => [
        ...builtins,
        for (final f in fields) _fieldSpec(f),
      ];

  /// Stored prefs merged over the registry: stored order first (unknown keys
  /// dropped — e.g. a deleted field's column), then any registry columns the
  /// prefs don't know yet (e.g. a newly added field, appended visible).
  static List<ColumnPref> effectivePrefs(
      List<ColumnPref> stored, List<_TaskColumnSpec> registry) {
    final known = registry.map((c) => c.key).toSet();
    final out = <ColumnPref>[
      for (final p in stored)
        if (known.contains(p.key)) p,
    ];
    final present = out.map((p) => p.key).toSet();
    for (final spec in registry) {
      if (!present.contains(spec.key)) {
        out.add(ColumnPref(key: spec.key, width: spec.defaultWidth));
      }
    }
    return out;
  }

  static _TaskColumnSpec? specIn(List<_TaskColumnSpec> registry, String key) {
    for (final s in registry) {
      if (s.key == key) return s;
    }
    return null;
  }

  List<_TaskColumnSpec> get _registry => registryWith(
      ref.watch(taskFieldConfigsProvider).valueOrNull ?? const []);

  _TaskColumnSpec _specFor(String key) => specIn(_registry, key)!;

  List<ColumnPref> get _prefs => effectiveTaskColumns(ref);

  void _updatePrefs(List<ColumnPref> next) => setTaskColumnPrefs(ref, next);

  // --- cell interactions (unchanged from UI-3a) ---

  Future<void> _pickStatus(BuildContext context, TaskVm task) async {
    final picked = await showStatusPicker(context, current: task.status);
    if (picked != null && picked != task.status) widget.onSetStatus(task, picked);
  }

  Future<void> _pickDue(BuildContext context, TaskVm task) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: task.dueAt ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      helpText: 'Due date for "${task.title}"',
    );
    if (picked != null) widget.onSetDue(task, picked);
  }

  Widget _dueCell(BuildContext context, TaskVm t) {
    final c = MakerflowTheme.of(context).colors;
    final overdue =
        t.dueAt != null && t.status != 'done' && t.dueAt!.isBefore(DateTime.now());
    return Semantics(
      button: true,
      label: t.dueAt == null
          ? 'Set due date for ${t.title}'
          : 'Due ${_fmtDate(t.dueAt!)}${overdue ? ', overdue' : ''}. Change due date',
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _pickDue(context, t),
        child: Center(
          child: overdue
              ? Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.error_outline, size: 14, color: c.danger),
                  const SizedBox(width: MndSpace.s4),
                  Text(_fmtDate(t.dueAt!),
                      style: TextStyle(
                          fontSize: 13, color: c.danger, fontWeight: FontWeight.w600)),
                ])
              : Text(t.dueAt == null ? '—' : _fmtDate(t.dueAt!),
                  style: TextStyle(
                      fontSize: 13, color: t.dueAt == null ? c.muted : c.text)),
        ),
      ),
    );
  }

  // --- column operations ---

  void _resizeColumn(String key, double delta) {
    final spec = _specFor(key);
    final next = [
      for (final p in _prefs)
        p.key == key
            ? p.copyWith(
                width: (p.width + delta)
                    .clamp(spec.minWidth, _TaskColumnSpec.maxWidth))
            : p,
    ];
    _updatePrefs(next);
  }

  /// Double-tap autofit: widest cell/header text + padding, clamped.
  void _autofitColumn(String key) {
    final spec = _specFor(key);
    var widest = _measure(spec.label, FontWeight.w400, 12);
    for (final t in widget.tasks) {
      final w = _measure(spec.textOf(t), FontWeight.w600, 13);
      if (w > widest) widest = w;
    }
    final target =
        (widest + MndSpace.s24 + MndSpace.s8).clamp(spec.minWidth, _TaskColumnSpec.maxWidth);
    _updatePrefs([
      for (final p in _prefs) p.key == key ? p.copyWith(width: target) : p,
    ]);
  }

  double _measure(String text, FontWeight weight, double size) {
    final painter = TextPainter(
      text: TextSpan(
          text: text, style: TextStyle(fontSize: size, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  void _moveColumn(String key, String beforeKey) {
    if (key == beforeKey) return;
    final prefs = List.of(_prefs);
    final moving = prefs.firstWhere((p) => p.key == key);
    prefs.removeWhere((p) => p.key == key);
    final at = prefs.indexWhere((p) => p.key == beforeKey);
    prefs.insert(at < 0 ? prefs.length : at, moving);
    _updatePrefs(prefs);
  }

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(MndSpace.s16, MndSpace.s8, MndSpace.s16, MndSpace.s48),
      children: [
        _StatusBattery(tasks: widget.tasks),
        const SizedBox(height: MndSpace.s12),
        for (final status in kanbanColumns) ..._group(context, c, status),
      ],
    );
  }

  List<Widget> _group(BuildContext context, MakerflowColors c, String status) {
    final groupColor = MndLabelColors.status[status] ?? MndLabelColors.blank;
    final rows = widget.tasks.where((t) => t.status == status).toList();
    final collapsed = _collapsed.contains(status);
    final registry = _registry;
    final visibleCols = _prefs.where((p) => !p.hidden).toList();

    return [
      Padding(
        padding: const EdgeInsets.only(top: MndSpace.s12, bottom: MndSpace.s4),
        child: Row(children: [
          IconButton(
            tooltip: collapsed ? 'Expand ${_label(status)}' : 'Collapse ${_label(status)}',
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            icon: Icon(collapsed ? Icons.chevron_right : Icons.expand_more, color: groupColor),
            onPressed: () => setState(() {
              collapsed ? _collapsed.remove(status) : _collapsed.add(status);
            }),
          ),
          Semantics(
            header: true,
            child: Text(_label(status),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: groupColor)),
          ),
          const SizedBox(width: MndSpace.s8),
          Text('${rows.length} ${rows.length == 1 ? 'item' : 'items'}',
              style: TextStyle(fontSize: 12, color: c.muted)),
        ]),
      ),
      if (!collapsed) ...[
        _headerRow(context, c, registry, visibleCols),
        for (final t in rows) _row(context, c, groupColor, t, registry, visibleCols),
        _AddItemRow(
          status: status,
          groupColor: groupColor,
          onSubmit: (title) => widget.onAddItem(status, title),
        ),
      ],
    ];
  }

  /// Column headers: draggable (reorder), with a resize handle on each right
  /// boundary (drag = resize, double-tap = autofit).
  Widget _headerRow(BuildContext context, MakerflowColors c,
      List<_TaskColumnSpec> registry, List<ColumnPref> cols) {
    return Container(
      height: 30,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(children: [
        const SizedBox(width: MndSpace.s8),
        Expanded(child: Text('Item', style: TextStyle(fontSize: 12, color: c.muted))),
        for (final p in cols) ...[
          _headerCell(context, c, registry, p),
          _resizeHandle(context, c, p),
        ],
      ]),
    );
  }

  Widget _headerCell(BuildContext context, MakerflowColors c,
      List<_TaskColumnSpec> registry, ColumnPref p) {
    final spec = specIn(registry, p.key)!;
    final header = SizedBox(
      width: p.width - 6, // the resize handle owns the last 6px
      child: Center(
        child: Text(spec.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: c.muted)),
      ),
    );
    // Drag a header onto another to reorder (drop inserts BEFORE the target).
    // The drop indicator is a foregroundDecoration so it never shifts layout
    // (headers must stay pixel-aligned with the data cells below).
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data != p.key,
      onAcceptWithDetails: (d) => _moveColumn(d.data, p.key),
      builder: (context, candidates, _) => Container(
        foregroundDecoration: candidates.isEmpty
            ? null
            : BoxDecoration(
                border: Border(left: BorderSide(color: c.brand, width: 2)),
              ),
        child: Draggable<String>(
          data: p.key,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: MndSpace.s12, vertical: MndSpace.s4),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(MakerflowShape.radiusSmall),
                boxShadow: MndShadows.medium,
              ),
              child: Text(spec.label, style: TextStyle(fontSize: 12, color: c.text)),
            ),
          ),
          child: header,
        ),
      ),
    );
  }

  Widget _resizeHandle(BuildContext context, MakerflowColors c, ColumnPref p) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        key: ValueKey('resize:${p.key}'),
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => _resizeColumn(p.key, d.delta.dx),
        onDoubleTap: () => _autofitColumn(p.key),
        child: SizedBox(
          width: 6,
          height: 30,
          child: Center(
            child: Container(width: 1, color: c.borderControl),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, MakerflowColors c, Color groupColor,
      TaskVm t, List<_TaskColumnSpec> registry, List<ColumnPref> cols) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: groupColor, width: 4),
          bottom: BorderSide(color: c.line),
        ),
      ),
      child: Row(children: [
        const SizedBox(width: MndSpace.s8),
        Expanded(
          child: Semantics(
            button: true,
            label: 'Open ${t.title}',
            excludeSemantics: true,
            child: InkWell(
              onTap: () => widget.onOpen(t),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: c.text)),
              ),
            ),
          ),
        ),
        for (final p in cols)
          SizedBox(
            width: p.width,
            height: 36,
            child: specIn(registry, p.key)!.cellBuilder(context, t, this),
          ),
      ]),
    );
  }
}

/// The Columns popover — show/hide toggles, Up/Down reorder buttons, AND the
/// custom-field manager (add/edit/delete definitions; server gates mutations
/// to workspaceAdmin+ and its typed Forbidden surfaces in the field dialog).
/// This is the REQUIRED keyboard/AT path for column reorder (headers are
/// pointer-draggable only) and the discoverability hub for the column system.
Future<void> showColumnsPopover(BuildContext context, WidgetRef ref) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Consumer(builder: (ctx2, popRef, _) {
      final fields =
          popRef.watch(taskFieldConfigsProvider).valueOrNull ?? const <FieldConfigVm>[];
      final registry = _MainTableViewState.registryWith(fields);
      final prefs = effectiveTaskColumns(popRef);
      final c = MakerflowTheme.of(ctx2).colors;
      void update(List<ColumnPref> next) => setTaskColumnPrefs(popRef, next);

      return AlertDialog(
        title: const Text('Columns'),
        content: SizedBox(
          width: 360,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < prefs.length; i++)
                  _columnRow(ctx2, popRef, registry, prefs, i, update),
                const SizedBox(height: MndSpace.s8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => update([
                      for (final spec in registry)
                        ColumnPref(key: spec.key, width: spec.defaultWidth),
                    ]),
                    child: const Text('Reset columns'),
                  ),
                ),
                Divider(color: c.line),
                Row(
                  children: [
                    Expanded(
                      child: Text('Custom fields',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: c.muted)),
                    ),
                    TextButton.icon(
                      key: const ValueKey('add-field'),
                      onPressed: () => showFieldDialog(ctx2, popRef),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add field'),
                    ),
                  ],
                ),
                if (fields.isEmpty)
                  Text('No custom fields yet — add one to grow the table.',
                      style: TextStyle(fontSize: 12, color: c.muted)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx2).pop(), child: const Text('Done')),
        ],
      );
    }),
  );
}

Widget _columnRow(
  BuildContext context,
  WidgetRef ref,
  List<_TaskColumnSpec> registry,
  List<ColumnPref> prefs,
  int i,
  void Function(List<ColumnPref>) update,
) {
  final spec = _MainTableViewState.specIn(registry, prefs[i].key)!;
  final field = spec.field;
  return Row(children: [
    Expanded(child: Text(spec.label, style: const TextStyle(fontSize: 14))),
    if (field != null) ...[
      IconButton(
        tooltip: 'Edit field ${spec.label}',
        iconSize: 16,
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.edit_outlined),
        onPressed: () => showFieldDialog(context, ref, existing: field),
      ),
      IconButton(
        tooltip: 'Delete field ${spec.label}',
        iconSize: 16,
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.delete_outline),
        onPressed: () => confirmDeleteField(context, ref, field),
      ),
    ],
    IconButton(
      tooltip: 'Move ${spec.label} up',
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.arrow_upward),
      onPressed: i == 0
          ? null
          : () {
              final next = List.of(prefs);
              final p = next.removeAt(i);
              next.insert(i - 1, p);
              update(next);
            },
    ),
    IconButton(
      tooltip: 'Move ${spec.label} down',
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.arrow_downward),
      onPressed: i == prefs.length - 1
          ? null
          : () {
              final next = List.of(prefs);
              final p = next.removeAt(i);
              next.insert(i + 1, p);
              update(next);
            },
    ),
    Semantics(
      label: '${spec.label} visible',
      child: Switch(
        value: !prefs[i].hidden,
        onChanged: (v) => update([
          for (final p in prefs)
            p.key == prefs[i].key ? p.copyWith(hidden: !v) : p,
        ]),
      ),
    ),
  ]);
}

/// The ghost "+ Add item" row: type + Enter creates in this group and keeps
/// focus for rapid entry (monday's add-item chaining).
class _AddItemRow extends StatefulWidget {
  const _AddItemRow({required this.status, required this.groupColor, required this.onSubmit});
  final String status;
  final Color groupColor;
  final ValueChanged<String> onSubmit;

  @override
  State<_AddItemRow> createState() => _AddItemRowState();
}

class _AddItemRowState extends State<_AddItemRow> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final title = value.trim();
    if (title.isEmpty) return;
    widget.onSubmit(title);
    _controller.clear();
    _focus.requestFocus(); // chain: keep typing the next item
  }

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: widget.groupColor.withValues(alpha: 0.4), width: 4),
          bottom: BorderSide(color: c.line),
        ),
      ),
      child: Row(children: [
        const SizedBox(width: MndSpace.s8),
        Icon(Icons.add, size: 16, color: c.muted),
        const SizedBox(width: MndSpace.s4),
        Expanded(
          child: TextField(
            key: ValueKey('add-item:${widget.status}'),
            controller: _controller,
            focusNode: _focus,
            onSubmitted: _submit,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: '+ Add item',
              hintStyle: TextStyle(color: c.muted, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: MndSpace.s8),
            ),
          ),
        ),
      ]),
    );
  }
}

/// Board-level status battery: a stacked bar of the visible tasks' status mix
/// in label colors, with a full text equivalent for AT (WCAG 1.1.1/1.4.1).
class _StatusBattery extends StatelessWidget {
  const _StatusBattery({required this.tasks});
  final List<TaskVm> tasks;

  @override
  Widget build(BuildContext context) {
    final c = MakerflowTheme.of(context).colors;
    if (tasks.isEmpty) return const SizedBox.shrink();
    final counts = <String, int>{};
    for (final t in tasks) {
      counts[t.status] = (counts[t.status] ?? 0) + 1;
    }
    final total = tasks.length;
    final donePct = ((counts['done'] ?? 0) * 100 / total).round();
    final summary = kanbanColumns
        .where((s) => (counts[s] ?? 0) > 0)
        .map((s) => '${counts[s]} ${StatusLabel.labels[s] ?? s}')
        .join(', ');

    return Semantics(
      label: 'Board progress: $donePct percent done. $summary.',
      excludeSemantics: true,
      child: Row(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(MakerflowShape.radiusSmall),
            child: SizedBox(
              height: 10,
              child: Row(children: [
                for (final s in kanbanColumns)
                  if ((counts[s] ?? 0) > 0)
                    Expanded(
                      flex: counts[s]!,
                      child: Tooltip(
                        message: '${StatusLabel.labels[s] ?? s}: ${counts[s]} of $total',
                        child: Container(color: MndLabelColors.status[s] ?? MndLabelColors.blank),
                      ),
                    ),
              ]),
            ),
          ),
        ),
        const SizedBox(width: MndSpace.s8),
        Text('$donePct% done', style: TextStyle(fontSize: 12, color: c.muted)),
      ]),
    );
  }
}
