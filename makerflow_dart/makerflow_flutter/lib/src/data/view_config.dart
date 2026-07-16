import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'field_models.dart';
import 'feature_models.dart';
import 'models.dart';

/// fl-8-filter-sort-group: the per-view FILTER / SORT / GROUP-BY configuration
/// — model, JSON codec (stored in `CustomView.filtersJson`), field registry,
/// and the client-side evaluator. Pure Dart: no widgets, fully unit-testable.
///
/// Field ids match the column registry where one exists: built-ins are
/// `title | status | priority | due | project | assignee`; custom fields are
/// `cf:<FieldConfig.key>`.

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class FilterCondition {
  const FilterCondition({required this.field, required this.op, this.value});
  final String field;
  final String op;
  final Object? value;

  Map<String, dynamic> toJson() =>
      {'field': field, 'op': op, if (value != null) 'value': value};
  static FilterCondition? fromJson(Object? o) {
    if (o is! Map<String, dynamic>) return null;
    final field = o['field'];
    final op = o['op'];
    if (field is! String || op is! String) return null;
    return FilterCondition(field: field, op: op, value: o['value']);
  }
}

/// One AND/OR group of condition rows (the spec's single level of nesting:
/// groups combine via [ViewConfig.join], rows inside via [join]).
class FilterGroup {
  const FilterGroup({this.join = 'and', this.conditions = const []});
  final String join; // and | or
  final List<FilterCondition> conditions;

  Map<String, dynamic> toJson() => {
        'join': join,
        'conditions': [for (final c in conditions) c.toJson()],
      };
  static FilterGroup? fromJson(Object? o) {
    if (o is! Map<String, dynamic>) return null;
    final raw = o['conditions'];
    return FilterGroup(
      join: o['join'] == 'or' ? 'or' : 'and',
      conditions: raw is! List
          ? const []
          : raw.map(FilterCondition.fromJson).whereType<FilterCondition>().toList(),
    );
  }
}

class SortKey {
  const SortKey({required this.field, this.desc = false});
  final String field;
  final bool desc;

  Map<String, dynamic> toJson() => {'field': field, 'desc': desc};
  static SortKey? fromJson(Object? o) {
    if (o is! Map<String, dynamic> || o['field'] is! String) return null;
    return SortKey(field: o['field'] as String, desc: o['desc'] == true);
  }
}

class ViewConfig {
  const ViewConfig({
    this.join = 'and',
    this.groups = const [],
    this.sorts = const [],
    this.groupBy = 'status',
  });

  static const empty = ViewConfig();

  final String join; // how filter GROUPS combine: and | or
  final List<FilterGroup> groups;
  final List<SortKey> sorts;
  final String groupBy; // a groupable field id; 'status' is the default

  bool get hasFilter => groups.any((g) => g.conditions.isNotEmpty);
  int get conditionCount =>
      groups.fold(0, (n, g) => n + g.conditions.length);
  bool get isDefault =>
      !hasFilter && sorts.isEmpty && groupBy == 'status';

  ViewConfig copyWith(
          {String? join,
          List<FilterGroup>? groups,
          List<SortKey>? sorts,
          String? groupBy}) =>
      ViewConfig(
        join: join ?? this.join,
        groups: groups ?? this.groups,
        sorts: sorts ?? this.sorts,
        groupBy: groupBy ?? this.groupBy,
      );

  String encode() => jsonEncode({
        'join': join,
        'groups': [for (final g in groups) g.toJson()],
        'sorts': [for (final s in sorts) s.toJson()],
        'groupBy': groupBy,
      });

  /// Tolerant decode (malformed/legacy '{}' → [empty]).
  static ViewConfig decode(String? json) {
    if (json == null || json.trim().isEmpty) return empty;
    try {
      final raw = jsonDecode(json);
      if (raw is! Map<String, dynamic>) return empty;
      final groups = raw['groups'];
      final sorts = raw['sorts'];
      return ViewConfig(
        join: raw['join'] == 'or' ? 'or' : 'and',
        groups: groups is! List
            ? const []
            : groups.map(FilterGroup.fromJson).whereType<FilterGroup>().toList(),
        sorts: sorts is! List
            ? const []
            : sorts.map(SortKey.fromJson).whereType<SortKey>().toList(),
        groupBy: raw['groupBy'] is String ? raw['groupBy'] as String : 'status',
      );
    } catch (_) {
      return empty;
    }
  }
}

// ---------------------------------------------------------------------------
// Field registry
// ---------------------------------------------------------------------------

/// How a field filters/sorts/groups. `option` = single choice from a list,
/// `multi` = list of choices, the rest are scalar kinds.
enum FieldKind { text, number, date, option, multi, boolean }

class FieldOptionDesc {
  const FieldOptionDesc(this.value, this.label, {this.color});
  final String value;
  final String label;
  final Color? color;
}

class FieldDescriptor {
  const FieldDescriptor({
    required this.id,
    required this.label,
    required this.kind,
    required this.valueOf,
    this.options = const [],
    this.groupable = false,
  });

  final String id;
  final String label;
  final FieldKind kind;
  final List<FieldOptionDesc> options;
  final bool groupable;

  /// The raw comparable value on a task (null = empty). Kinds: text→String,
  /// number→num, date→'YYYY-MM-DD' String, option→String value (project =
  /// projectId as String), multi→List<String>, boolean→bool.
  final Object? Function(TaskVm) valueOf;
}

/// Operators per kind (ids are stable; labels live in [operatorLabel]).
const operatorsByKind = <FieldKind, List<String>>{
  FieldKind.text: ['contains', 'notContains', 'is', 'isNot', 'isEmpty', 'isNotEmpty'],
  FieldKind.number: ['eq', 'neq', 'gt', 'gte', 'lt', 'lte', 'isEmpty', 'isNotEmpty'],
  FieldKind.date: ['is', 'before', 'after', 'isEmpty', 'isNotEmpty'],
  FieldKind.option: ['is', 'isNot', 'isEmpty', 'isNotEmpty'],
  FieldKind.multi: ['has', 'notHas', 'isEmpty', 'isNotEmpty'],
  FieldKind.boolean: ['isTrue', 'isFalse'],
};

const operatorLabel = <String, String>{
  'contains': 'contains', 'notContains': "doesn't contain",
  'is': 'is', 'isNot': 'is not',
  'eq': '=', 'neq': '≠', 'gt': '>', 'gte': '≥', 'lt': '<', 'lte': '≤',
  'before': 'is before', 'after': 'is after',
  'has': 'has', 'notHas': "doesn't have",
  'isEmpty': 'is empty', 'isNotEmpty': 'is not empty',
  'isTrue': 'is checked', 'isFalse': 'is unchecked',
};

/// Operators that take no value input.
const valuelessOps = {'isEmpty', 'isNotEmpty', 'isTrue', 'isFalse'};

const statusOrder = kanbanColumns; // backlog..done
const priorityOrder = ['low', 'medium', 'high', 'urgent'];

const priorityColors = <String, Color>{
  'low': MndLabelColors.americanGray,
  'medium': MndLabelColors.brightBlue,
  'high': MndLabelColors.working,
  'urgent': MndLabelColors.stuck,
};

String _statusLabel(String s) => StatusLabel.labels[s] ?? s;
String _cap(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
String _dateOnly(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Build the full field registry for the current org: built-ins + custom
/// fields. [projects] names the project options; [tasks] supplies the
/// dynamic assignee values.
List<FieldDescriptor> buildFieldDescriptors({
  required List<FieldConfigVm> fieldConfigs,
  required List<ProjectVm> projects,
  required List<TaskVm> tasks,
}) {
  final assignees = <String>{
    for (final t in tasks)
      if (t.assigneeName != null) t.assigneeName!,
  }.toList()
    ..sort();

  return [
    FieldDescriptor(
      id: 'title',
      label: 'Item',
      kind: FieldKind.text,
      valueOf: (t) => t.title,
    ),
    FieldDescriptor(
      id: 'status',
      label: 'Status',
      kind: FieldKind.option,
      groupable: true,
      options: [
        for (final s in statusOrder)
          FieldOptionDesc(s, _statusLabel(s),
              color: MndLabelColors.status[s] ?? MndLabelColors.blank),
      ],
      valueOf: (t) => t.status,
    ),
    FieldDescriptor(
      id: 'priority',
      label: 'Priority',
      kind: FieldKind.option,
      groupable: true,
      options: [
        for (final p in priorityOrder)
          FieldOptionDesc(p, _cap(p), color: priorityColors[p]),
      ],
      valueOf: (t) => t.priority,
    ),
    FieldDescriptor(
      id: 'due',
      label: 'Due date',
      kind: FieldKind.date,
      valueOf: (t) => t.dueAt == null ? null : _dateOnly(t.dueAt!),
    ),
    FieldDescriptor(
      id: 'project',
      label: 'Project',
      kind: FieldKind.option,
      groupable: true,
      options: [
        for (final p in projects) FieldOptionDesc('${p.id}', p.name),
      ],
      valueOf: (t) => t.projectId == null ? null : '${t.projectId}',
    ),
    FieldDescriptor(
      id: 'assignee',
      label: 'Assignee',
      kind: FieldKind.option,
      groupable: true,
      options: [for (final a in assignees) FieldOptionDesc(a, a)],
      valueOf: (t) => t.assigneeName,
    ),
    for (final f in fieldConfigs) _customDescriptor(f),
  ];
}

FieldDescriptor _customDescriptor(FieldConfigVm f) {
  final id = 'cf:${f.key}';
  Object? raw(TaskVm t) => t.customFields[f.key];
  switch (f.fieldType) {
    case 'number':
      return FieldDescriptor(
          id: id, label: f.label, kind: FieldKind.number,
          valueOf: (t) => raw(t) is num ? raw(t) as num : null);
    case 'date':
      return FieldDescriptor(
          id: id, label: f.label, kind: FieldKind.date,
          valueOf: (t) {
            final v = raw(t);
            final d = v is String ? DateTime.tryParse(v) : null;
            return d == null ? null : _dateOnly(d);
          });
    case 'checkbox':
      return FieldDescriptor(
          id: id, label: f.label, kind: FieldKind.boolean, groupable: true,
          valueOf: (t) => raw(t) == true);
    case 'multiSelect':
      return FieldDescriptor(
          id: id, label: f.label, kind: FieldKind.multi,
          options: [for (final o in f.options) FieldOptionDesc(o.value, o.value, color: o.color)],
          valueOf: (t) =>
              raw(t) is List ? (raw(t) as List).whereType<String>().toList() : null);
    case 'select':
    case 'label':
      return FieldDescriptor(
          id: id, label: f.label, kind: FieldKind.option, groupable: true,
          options: [for (final o in f.options) FieldOptionDesc(o.value, o.value, color: o.color)],
          valueOf: (t) => raw(t) is String ? raw(t) as String : null);
    case 'person':
      return FieldDescriptor(
          id: id, label: f.label, kind: FieldKind.option, groupable: true,
          valueOf: (t) => raw(t) is int ? 'User #${raw(t)}' : null);
    default: // text / longText
      return FieldDescriptor(
          id: id, label: f.label, kind: FieldKind.text,
          valueOf: (t) => raw(t) is String ? raw(t) as String : null);
  }
}

FieldDescriptor? descriptorFor(List<FieldDescriptor> fields, String id) {
  for (final f in fields) {
    if (f.id == id) return f;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Evaluation
// ---------------------------------------------------------------------------

bool _isEmptyValue(Object? v) =>
    v == null || (v is String && v.isEmpty) || (v is List && v.isEmpty);

bool _conditionMatches(
    FilterCondition c, TaskVm task, List<FieldDescriptor> fields) {
  final field = descriptorFor(fields, c.field);
  if (field == null) return true; // unknown field (e.g. deleted) → ignore
  final v = field.valueOf(task);
  final want = c.value;
  switch (c.op) {
    case 'isEmpty':
      return _isEmptyValue(v);
    case 'isNotEmpty':
      return !_isEmptyValue(v);
    case 'isTrue':
      return v == true;
    case 'isFalse':
      return v != true;
    case 'contains':
      return v is String &&
          want is String &&
          v.toLowerCase().contains(want.toLowerCase());
    case 'notContains':
      return !(v is String &&
          want is String &&
          v.toLowerCase().contains(want.toLowerCase()));
    case 'is':
      if (field.kind == FieldKind.date) {
        return v is String && want is String && v == want;
      }
      return v is String &&
          want is String &&
          v.toLowerCase() == want.toLowerCase();
    case 'isNot':
      return !(v is String &&
          want is String &&
          v.toLowerCase() == want.toLowerCase());
    case 'before':
      return v is String && want is String && v.compareTo(want) < 0;
    case 'after':
      return v is String && want is String && v.compareTo(want) > 0;
    case 'has':
      return v is List && want is String && v.contains(want);
    case 'notHas':
      return !(v is List && want is String && v.contains(want));
    case 'eq':
    case 'neq':
    case 'gt':
    case 'gte':
    case 'lt':
    case 'lte':
      final n = v is num ? v : null;
      final w = want is num ? want : (want is String ? num.tryParse(want) : null);
      if (n == null || w == null) return c.op == 'neq';
      return switch (c.op) {
        'eq' => n == w,
        'neq' => n != w,
        'gt' => n > w,
        'gte' => n >= w,
        'lt' => n < w,
        _ => n <= w,
      };
    default:
      return true; // unknown operator → ignore
  }
}

/// Apply the config's filter: groups of conditions, rows joined by the
/// group's join, groups joined by the top-level join.
List<TaskVm> applyFilter(
    List<TaskVm> tasks, ViewConfig config, List<FieldDescriptor> fields) {
  final groups =
      config.groups.where((g) => g.conditions.isNotEmpty).toList();
  if (groups.isEmpty) return tasks;
  bool groupMatches(FilterGroup g, TaskVm t) => g.join == 'or'
      ? g.conditions.any((c) => _conditionMatches(c, t, fields))
      : g.conditions.every((c) => _conditionMatches(c, t, fields));
  return [
    for (final t in tasks)
      if (config.join == 'or'
          ? groups.any((g) => groupMatches(g, t))
          : groups.every((g) => groupMatches(g, t)))
        t,
  ];
}

int _compareField(TaskVm a, TaskVm b, FieldDescriptor field) {
  final va = field.valueOf(a);
  final vb = field.valueOf(b);
  if (_isEmptyValue(va) && _isEmptyValue(vb)) return 0;
  if (_isEmptyValue(va)) return 1; // empties last, both directions
  if (_isEmptyValue(vb)) return -1;
  switch (field.kind) {
    case FieldKind.number:
      return (va as num).compareTo(vb as num);
    case FieldKind.boolean:
      return (va == true ? 1 : 0).compareTo(vb == true ? 1 : 0);
    case FieldKind.option:
      // Ordered option lists (status/priority/labels) sort by option order;
      // dynamic options (assignee/project) fall back to label order.
      if (field.options.isNotEmpty) {
        final ia = field.options.indexWhere((o) => o.value == va);
        final ib = field.options.indexWhere((o) => o.value == vb);
        if (ia >= 0 && ib >= 0) return ia.compareTo(ib);
      }
      return va.toString().toLowerCase().compareTo(vb.toString().toLowerCase());
    case FieldKind.multi:
      return (va as List).join(',').compareTo((vb as List).join(','));
    case FieldKind.date:
    case FieldKind.text:
      return va.toString().toLowerCase().compareTo(vb.toString().toLowerCase());
  }
}

/// Multi-level sort; empties always last; stable for untouched rows.
List<TaskVm> applySort(
    List<TaskVm> tasks, ViewConfig config, List<FieldDescriptor> fields) {
  if (config.sorts.isEmpty) return tasks;
  final keyed = [
    for (final s in config.sorts)
      if (descriptorFor(fields, s.field) != null)
        (descriptorFor(fields, s.field)!, s.desc),
  ];
  if (keyed.isEmpty) return tasks;
  final out = List.of(tasks);
  out.sort((a, b) {
    for (final (field, desc) in keyed) {
      // Empties sort last in BOTH directions (outside the desc flip).
      final ea = _isEmptyValue(field.valueOf(a));
      final eb = _isEmptyValue(field.valueOf(b));
      if (ea != eb) return ea ? 1 : -1;
      if (ea && eb) continue;
      final c = _compareField(a, b, field);
      if (c != 0) return desc ? -c : c;
    }
    return 0;
  });
  return out;
}

// ---------------------------------------------------------------------------
// Grouping
// ---------------------------------------------------------------------------

class TaskGroup {
  const TaskGroup(
      {required this.key, required this.label, required this.color, required this.tasks});
  final String key; // '<fieldId>:<value>' — stable collapse/add-item key
  final String label;
  final Color color;
  final List<TaskVm> tasks;
}

/// Group [tasks] by [config.groupBy]. Status keeps today's exact behavior
/// (all six groups, kanban order, status keys). Fields with a defined option
/// list show every option (empty groups included, so items can be added into
/// them) + a "No X" group when needed; dynamic fields show present values.
List<TaskGroup> computeGroups(
    List<TaskVm> tasks, ViewConfig config, List<FieldDescriptor> fields) {
  final field = descriptorFor(fields, config.groupBy);
  if (field == null || config.groupBy == 'status') {
    return [
      for (final s in statusOrder)
        TaskGroup(
          key: s, // bare status keys — collapse state + tests predate grouping
          label: _statusLabel(s),
          color: MndLabelColors.status[s] ?? MndLabelColors.blank,
          tasks: [for (final t in tasks) if (t.status == s) t],
        ),
    ];
  }

  String valueKey(TaskVm t) {
    final v = field.valueOf(t);
    if (field.kind == FieldKind.boolean) return v == true ? 'true' : 'false';
    return _isEmptyValue(v) ? '' : v.toString();
  }

  final byValue = <String, List<TaskVm>>{};
  for (final t in tasks) {
    byValue.putIfAbsent(valueKey(t), () => []).add(t);
  }

  Color colorAt(int i, Color? own) =>
      own ?? MndLabelColors.groups[i % MndLabelColors.groups.length];

  final groups = <TaskGroup>[];
  if (field.kind == FieldKind.boolean) {
    groups.add(TaskGroup(
        key: '${field.id}:true', label: field.label, color: MndLabelColors.done,
        tasks: byValue['true'] ?? const []));
    groups.add(TaskGroup(
        key: '${field.id}:false', label: 'Not ${field.label.toLowerCase()}',
        color: MndLabelColors.blank, tasks: byValue['false'] ?? const []));
    return groups;
  }

  if (field.options.isNotEmpty) {
    for (final (i, o) in field.options.indexed) {
      groups.add(TaskGroup(
          key: '${field.id}:${o.value}', label: o.label,
          color: colorAt(i, o.color), tasks: byValue[o.value] ?? const []));
    }
  } else {
    final present = byValue.keys.where((k) => k.isNotEmpty).toList()..sort();
    for (final (i, v) in present.indexed) {
      groups.add(TaskGroup(
          key: '${field.id}:$v', label: v, color: colorAt(i, null),
          tasks: byValue[v]!));
    }
  }
  final none = byValue[''] ?? const [];
  if (none.isNotEmpty) {
    groups.add(TaskGroup(
        key: '${field.id}:', label: 'No ${field.label.toLowerCase()}',
        color: MndLabelColors.blank, tasks: none));
  }
  return groups;
}
