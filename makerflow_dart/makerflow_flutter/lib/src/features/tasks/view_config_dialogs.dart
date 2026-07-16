import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../data/view_config.dart';
import '../../state/providers.dart';

/// fl-8-filter-sort-group dialogs: the Airtable-style FILTER builder
/// (AND/OR groups of per-type condition rows), the multi-level SORT editor,
/// and the GROUP-BY picker. All three edit [taskViewConfigProvider]; the
/// caller passes [onApply] so it can announce the fresh result count
/// (WCAG 4.1.3) after the provider updates.

// ---------------------------------------------------------------------------
// Filter builder
// ---------------------------------------------------------------------------

Future<void> showFilterBuilder(BuildContext context, WidgetRef ref,
    List<FieldDescriptor> fields, VoidCallback onApply) {
  // Draft-edit a deep copy; Apply commits (typing must not refilter live).
  var draft = ref.read(taskViewConfigProvider);
  if (draft.groups.isEmpty) {
    draft = draft.copyWith(groups: [const FilterGroup()]);
  }
  return showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx2, setState) {
        final c = MakerflowTheme.of(ctx2).colors;

        void update(ViewConfig next) => setState(() => draft = next);

        void setGroup(int gi, FilterGroup g) {
          final groups = List.of(draft.groups);
          groups[gi] = g;
          update(draft.copyWith(groups: groups));
        }

        void setCondition(int gi, int ci, FilterCondition cond) {
          final conds = List.of(draft.groups[gi].conditions);
          conds[ci] = cond;
          setGroup(gi, FilterGroup(join: draft.groups[gi].join, conditions: conds));
        }

        Widget joinToggle(String value, ValueChanged<String> onChanged,
            {required String semantics}) {
          return Semantics(
            label: semantics,
            child: SegmentedButton<String>(
              style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              segments: const [
                ButtonSegment(value: 'and', label: Text('AND')),
                ButtonSegment(value: 'or', label: Text('OR')),
              ],
              selected: {value},
              onSelectionChanged: (s) => onChanged(s.first),
            ),
          );
        }

        Widget conditionRow(int gi, int ci) {
          final cond = draft.groups[gi].conditions[ci];
          final field = descriptorFor(fields, cond.field) ?? fields.first;
          final ops = operatorsByKind[field.kind]!;
          final op = ops.contains(cond.op) ? cond.op : ops.first;
          return Padding(
            padding: const EdgeInsets.only(top: MndSpace.s8),
            child: Row(children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: field.id,
                  decoration: const InputDecoration(labelText: 'Field', isDense: true),
                  items: [
                    for (final f in fields)
                      DropdownMenuItem(value: f.id, child: Text(f.label)),
                  ],
                  onChanged: (id) {
                    if (id == null) return;
                    final nf = descriptorFor(fields, id)!;
                    setCondition(gi, ci,
                        FilterCondition(field: id, op: operatorsByKind[nf.kind]!.first));
                  },
                ),
              ),
              const SizedBox(width: MndSpace.s8),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: op,
                  decoration:
                      const InputDecoration(labelText: 'Condition', isDense: true),
                  items: [
                    for (final o in ops)
                      DropdownMenuItem(value: o, child: Text(operatorLabel[o] ?? o)),
                  ],
                  onChanged: (o) => setCondition(gi, ci,
                      FilterCondition(field: cond.field, op: o ?? op, value: cond.value)),
                ),
              ),
              const SizedBox(width: MndSpace.s8),
              Expanded(flex: 3, child: _valueEditor(ctx2, field, op, cond, (v) {
                setCondition(gi, ci,
                    FilterCondition(field: cond.field, op: op, value: v));
              })),
              IconButton(
                tooltip: 'Remove condition',
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close),
                onPressed: () {
                  final conds = List.of(draft.groups[gi].conditions)..removeAt(ci);
                  setGroup(gi,
                      FilterGroup(join: draft.groups[gi].join, conditions: conds));
                },
              ),
            ]),
          );
        }

        return AlertDialog(
          title: const Text('Filter'),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var gi = 0; gi < draft.groups.length; gi++) ...[
                    if (gi > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: MndSpace.s8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: joinToggle(draft.join,
                              (j) => update(draft.copyWith(join: j)),
                              semantics: 'How filter groups combine'),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                          MndSpace.s12, MndSpace.s4, MndSpace.s12, MndSpace.s12),
                      decoration: BoxDecoration(
                        border: Border.all(color: c.line),
                        borderRadius:
                            BorderRadius.circular(MakerflowShape.radiusControl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            Text('Where', style: TextStyle(color: c.muted)),
                            const Spacer(),
                            if (draft.groups[gi].conditions.length > 1)
                              joinToggle(
                                  draft.groups[gi].join,
                                  (j) => setGroup(
                                      gi,
                                      FilterGroup(
                                          join: j,
                                          conditions: draft.groups[gi].conditions)),
                                  semantics: 'How conditions in this group combine'),
                            if (draft.groups.length > 1)
                              IconButton(
                                tooltip: 'Remove group',
                                iconSize: 18,
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  final groups = List.of(draft.groups)..removeAt(gi);
                                  update(draft.copyWith(groups: groups));
                                },
                              ),
                          ]),
                          for (var ci = 0;
                              ci < draft.groups[gi].conditions.length;
                              ci++)
                            conditionRow(gi, ci),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              key: ValueKey('filter-add:$gi'),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add condition'),
                              onPressed: () => setGroup(
                                  gi,
                                  FilterGroup(
                                      join: draft.groups[gi].join,
                                      conditions: [
                                        ...draft.groups[gi].conditions,
                                        FilterCondition(
                                            field: fields.first.id,
                                            op: operatorsByKind[fields.first.kind]!
                                                .first),
                                      ])),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const ValueKey('filter-add-group'),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add group'),
                      onPressed: () => update(draft.copyWith(
                          groups: [...draft.groups, const FilterGroup()])),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              key: const ValueKey('filter-clear'),
              onPressed: () {
                ref.read(taskViewConfigProvider.notifier).state = ref
                    .read(taskViewConfigProvider)
                    .copyWith(groups: const [], join: 'and');
                Navigator.of(ctx2).pop();
                onApply();
              },
              child: const Text('Clear'),
            ),
            TextButton(
                onPressed: () => Navigator.of(ctx2).pop(),
                child: const Text('Cancel')),
            FilledButton(
              key: const ValueKey('filter-apply'),
              onPressed: () {
                ref.read(taskViewConfigProvider.notifier).state = draft;
                Navigator.of(ctx2).pop();
                onApply();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    ),
  );
}

Widget _valueEditor(BuildContext context, FieldDescriptor field, String op,
    FilterCondition cond, ValueChanged<Object?> onChanged) {
  if (valuelessOps.contains(op)) return const SizedBox.shrink();
  switch (field.kind) {
    case FieldKind.option:
    case FieldKind.multi:
      if (field.options.isEmpty) {
        return _textValue(cond, onChanged, hint: 'value');
      }
      final current = cond.value is String &&
              field.options.any((o) => o.value == cond.value)
          ? cond.value as String
          : null;
      return DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: current,
        decoration: const InputDecoration(labelText: 'Value', isDense: true),
        items: [
          for (final o in field.options)
            DropdownMenuItem(value: o.value, child: Text(o.label)),
        ],
        onChanged: onChanged,
      );
    case FieldKind.date:
      return OutlinedButton(
        onPressed: () async {
          final now = DateTime.now();
          final initial =
              cond.value is String ? DateTime.tryParse(cond.value as String) : null;
          final picked = await showDatePicker(
            context: context,
            initialDate: initial ?? now,
            firstDate: DateTime(now.year - 5),
            lastDate: DateTime(now.year + 5),
          );
          if (picked != null) {
            onChanged(picked.toIso8601String().split('T').first);
          }
        },
        child: Text(cond.value is String ? cond.value as String : 'Pick a date'),
      );
    case FieldKind.number:
      return _textValue(cond, (s) => onChanged(num.tryParse(s as String? ?? '')),
          hint: 'number', keyboard: TextInputType.number);
    case FieldKind.boolean:
      return const SizedBox.shrink(); // isTrue/isFalse carry the value
    case FieldKind.text:
      return _textValue(cond, onChanged, hint: 'text');
  }
}

Widget _textValue(FilterCondition cond, ValueChanged<Object?> onChanged,
    {required String hint, TextInputType? keyboard}) {
  return TextFormField(
    key: const ValueKey('filter-value'),
    initialValue: cond.value?.toString() ?? '',
    keyboardType: keyboard,
    decoration: InputDecoration(labelText: 'Value', hintText: hint, isDense: true),
    onChanged: onChanged,
  );
}

// ---------------------------------------------------------------------------
// Sort editor
// ---------------------------------------------------------------------------

Future<void> showSortEditor(BuildContext context, WidgetRef ref,
    List<FieldDescriptor> fields, VoidCallback onApply) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Consumer(builder: (ctx2, popRef, _) {
      final config = popRef.watch(taskViewConfigProvider);

      void commit(List<SortKey> sorts) {
        popRef.read(taskViewConfigProvider.notifier).state =
            config.copyWith(sorts: sorts);
        onApply();
      }

      return AlertDialog(
        title: const Text('Sort'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (config.sorts.isEmpty)
                Text('No sorting — rows keep their board order.',
                    style: TextStyle(
                        color: MakerflowTheme.of(ctx2).colors.muted)),
              for (var i = 0; i < config.sorts.length; i++)
                Row(children: [
                  Text('${i + 1}.'),
                  const SizedBox(width: MndSpace.s8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: descriptorFor(fields, config.sorts[i].field) != null
                          ? config.sorts[i].field
                          : null,
                      decoration: const InputDecoration(isDense: true),
                      items: [
                        for (final f in fields)
                          DropdownMenuItem(value: f.id, child: Text(f.label)),
                      ],
                      onChanged: (id) {
                        if (id == null) return;
                        final sorts = List.of(config.sorts);
                        sorts[i] = SortKey(field: id, desc: sorts[i].desc);
                        commit(sorts);
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: config.sorts[i].desc
                        ? 'Descending — switch to ascending'
                        : 'Ascending — switch to descending',
                    iconSize: 18,
                    icon: Icon(config.sorts[i].desc
                        ? Icons.arrow_downward
                        : Icons.arrow_upward),
                    onPressed: () {
                      final sorts = List.of(config.sorts);
                      sorts[i] =
                          SortKey(field: sorts[i].field, desc: !sorts[i].desc);
                      commit(sorts);
                    },
                  ),
                  IconButton(
                    tooltip: 'Remove sort level',
                    iconSize: 18,
                    icon: const Icon(Icons.close),
                    onPressed: () => commit(List.of(config.sorts)..removeAt(i)),
                  ),
                ]),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey('sort-add'),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add sort'),
                  onPressed: () =>
                      commit([...config.sorts, SortKey(field: fields.first.id)]),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (config.sorts.isNotEmpty)
            TextButton(
                key: const ValueKey('sort-clear'),
                onPressed: () => commit(const []),
                child: const Text('Clear')),
          TextButton(
              onPressed: () => Navigator.of(ctx2).pop(),
              child: const Text('Done')),
        ],
      );
    }),
  );
}

// ---------------------------------------------------------------------------
// Group-by picker
// ---------------------------------------------------------------------------

Future<void> showGroupByPicker(BuildContext context, WidgetRef ref,
    List<FieldDescriptor> fields, VoidCallback onApply) {
  final groupable = [for (final f in fields) if (f.groupable) f];
  return showDialog<void>(
    context: context,
    builder: (ctx) => Consumer(builder: (ctx2, popRef, _) {
      final config = popRef.watch(taskViewConfigProvider);
      return SimpleDialog(
        title: const Text('Group by'),
        children: [
          for (final f in groupable)
            Semantics(
              selected: config.groupBy == f.id,
              button: true,
              child: SimpleDialogOption(
                onPressed: () {
                  popRef.read(taskViewConfigProvider.notifier).state =
                      config.copyWith(groupBy: f.id);
                  Navigator.of(ctx2).pop();
                  onApply();
                },
                child: Row(children: [
                  Icon(
                      config.groupBy == f.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 18),
                  const SizedBox(width: MndSpace.s8),
                  Text(f.id == 'status' ? 'Status (default)' : f.label),
                ]),
              ),
            ),
        ],
      );
    }),
  );
}
