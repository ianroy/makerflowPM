import 'package:flutter/material.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../data/models.dart';

/// UI-3: monday's signature **Main Table** view.
/// Groups (by status, in board-column order) with colored, collapsible headers;
/// ~36px rows carrying a 4px group-colored bar on their left edge; inline
/// editing (status cell → label picker, due-date cell → date picker, row tap →
/// the edit dialog); a ghost "+ Add item" row per group (Enter creates and
/// keeps focus for rapid entry); and a board-level status battery.
///
/// A11y: group titles are semantic headers; every cell action is a focusable
/// button with an explicit label; the battery carries a text equivalent.
class MainTableView extends StatefulWidget {
  const MainTableView({
    super.key,
    required this.tasks,
    required this.onOpen,
    required this.onSetStatus,
    required this.onSetDue,
    required this.onAddItem,
  });

  final List<TaskVm> tasks;
  final ValueChanged<TaskVm> onOpen;
  final void Function(TaskVm task, String status) onSetStatus;
  final void Function(TaskVm task, DateTime due) onSetDue;
  final void Function(String status, String title) onAddItem;

  @override
  State<MainTableView> createState() => _MainTableViewState();
}

class _MainTableViewState extends State<MainTableView> {
  final Set<String> _collapsed = {};

  static const _statusColWidth = 150.0;
  static const _dueColWidth = 104.0;
  static const _priorityColWidth = 92.0;

  static String _label(String s) => StatusLabel.labels[s] ?? s;

  static String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

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

    return [
      // Group header: chevron + title in the group color + count.
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
        // Column header row.
        Container(
          height: 30,
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
          child: Row(children: [
            const SizedBox(width: MndSpace.s8),
            Expanded(child: Text('Item', style: TextStyle(fontSize: 12, color: c.muted))),
            SizedBox(width: _statusColWidth, child: Center(child: Text('Status', style: TextStyle(fontSize: 12, color: c.muted)))),
            SizedBox(width: _dueColWidth, child: Center(child: Text('Due date', style: TextStyle(fontSize: 12, color: c.muted)))),
            SizedBox(width: _priorityColWidth, child: Center(child: Text('Priority', style: TextStyle(fontSize: 12, color: c.muted)))),
          ]),
        ),
        for (final t in rows) _row(context, c, groupColor, t),
        _AddItemRow(
          status: status,
          groupColor: groupColor,
          onSubmit: (title) => widget.onAddItem(status, title),
        ),
      ],
    ];
  }

  Widget _row(BuildContext context, MakerflowColors c, Color groupColor, TaskVm t) {
    final overdue = t.dueAt != null &&
        t.status != 'done' &&
        t.dueAt!.isBefore(DateTime.now());
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
        // Item name — tap opens the edit dialog (same flow as the kanban card).
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
        // Status cell — full-bleed label, click → picker.
        SizedBox(
          width: _statusColWidth,
          height: 36,
          child: StatusLabel.cell(status: t.status, onTap: () => _pickStatus(context, t)),
        ),
        // Due-date cell (deadline mode: red when overdue and not done).
        SizedBox(
          width: _dueColWidth,
          height: 36,
          child: Semantics(
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
                            style: TextStyle(fontSize: 13, color: c.danger, fontWeight: FontWeight.w600)),
                      ])
                    : Text(t.dueAt == null ? '—' : _fmtDate(t.dueAt!),
                        style: TextStyle(fontSize: 13, color: t.dueAt == null ? c.muted : c.text)),
              ),
            ),
          ),
        ),
        SizedBox(
          width: _priorityColWidth,
          child: Center(
            child: Text(t.priority,
                style: TextStyle(fontSize: 13, color: c.muted)),
          ),
        ),
      ]),
    );
  }
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
