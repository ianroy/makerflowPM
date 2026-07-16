import 'package:flutter_test/flutter_test.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/data/field_models.dart';
import 'package:makerflow_flutter/src/data/feature_models.dart';
import 'package:makerflow_flutter/src/data/models.dart';
import 'package:makerflow_flutter/src/data/view_config.dart';

/// fl-8-filter-sort-group evaluator: pure-Dart contract tests for the codec,
/// filter semantics (AND/OR groups), multi-sort, and group-by.
TaskVm _t(int id, String title,
        {String status = 'todo',
        String priority = 'medium',
        int? projectId,
        String? assignee,
        DateTime? due,
        Map<String, dynamic> cf = const {}}) =>
    TaskVm(
        id: id,
        organizationId: 1,
        title: title,
        status: status,
        priority: priority,
        projectId: projectId,
        assigneeName: assignee,
        dueAt: due,
        customFields: cf);

void main() {
  final configs = [
    const FieldConfigVm(key: 'material', label: 'Material', fieldType: 'label', options: [
      FieldOption('Wood', color: MndLabelColors.brown),
      FieldOption('Metal', color: MndLabelColors.winter),
    ]),
    const FieldConfigVm(key: 'weight', label: 'Weight', fieldType: 'number'),
    const FieldConfigVm(key: 'tags', label: 'Tags', fieldType: 'multiSelect', options: [
      FieldOption('cnc'), FieldOption('laser'),
    ]),
    const FieldConfigVm(key: 'ok', label: 'Approved', fieldType: 'checkbox'),
  ];
  final projects = [ProjectVm(id: 1, name: 'Capstone', status: 'active')];
  final tasks = [
    _t(1, 'Cut plywood', status: 'todo', priority: 'high', assignee: 'Sam',
        cf: {'material': 'Wood', 'weight': 3.5, 'tags': ['cnc']}),
    _t(2, 'Weld frame', status: 'inProgress', priority: 'urgent', assignee: 'Jo',
        projectId: 1, cf: {'material': 'Metal', 'weight': 12, 'ok': true}),
    _t(3, 'Paint sign', status: 'done', priority: 'low',
        due: DateTime(2026, 7, 20), cf: {'weight': 1}),
  ];
  final fields = buildFieldDescriptors(
      fieldConfigs: configs, projects: projects, tasks: tasks);

  ViewConfig filter(List<FilterCondition> conds, {String join = 'and'}) =>
      ViewConfig(groups: [FilterGroup(join: join, conditions: conds)]);

  List<int> ids(List<TaskVm> ts) => [for (final t in ts) t.id];

  group('codec', () {
    test('round-trips and tolerates junk', () {
      const config = ViewConfig(
        join: 'or',
        groups: [
          FilterGroup(join: 'or', conditions: [
            FilterCondition(field: 'status', op: 'is', value: 'done'),
            FilterCondition(field: 'cf:weight', op: 'gt', value: 5),
          ]),
        ],
        sorts: [SortKey(field: 'due', desc: true)],
        groupBy: 'cf:material',
      );
      final back = ViewConfig.decode(config.encode());
      expect(back.join, 'or');
      expect(back.groups.single.conditions.length, 2);
      expect(back.groups.single.conditions[1].value, 5);
      expect(back.sorts.single.desc, isTrue);
      expect(back.groupBy, 'cf:material');

      expect(ViewConfig.decode('{}').isDefault, isTrue); // legacy filtersJson
      expect(ViewConfig.decode('not json').isDefault, isTrue);
      expect(ViewConfig.decode(null).isDefault, isTrue);
    });
  });

  group('filter', () {
    test('per-type operators', () {
      expect(ids(applyFilter(tasks, filter(const [FilterCondition(field: 'title', op: 'contains', value: 'ply')]), fields)), [1]);
      expect(ids(applyFilter(tasks, filter(const [FilterCondition(field: 'status', op: 'isNot', value: 'done')]), fields)), [1, 2]);
      expect(ids(applyFilter(tasks, filter(const [FilterCondition(field: 'cf:weight', op: 'gt', value: 3)]), fields)), [1, 2]);
      expect(ids(applyFilter(tasks, filter(const [FilterCondition(field: 'cf:tags', op: 'has', value: 'cnc')]), fields)), [1]);
      expect(ids(applyFilter(tasks, filter(const [FilterCondition(field: 'cf:ok', op: 'isTrue')]), fields)), [2]);
      expect(ids(applyFilter(tasks, filter(const [FilterCondition(field: 'due', op: 'after', value: '2026-07-01')]), fields)), [3]);
      expect(ids(applyFilter(tasks, filter(const [FilterCondition(field: 'due', op: 'isEmpty')]), fields)), [1, 2]);
      expect(ids(applyFilter(tasks, filter(const [FilterCondition(field: 'project', op: 'is', value: '1')]), fields)), [2]);
      expect(ids(applyFilter(tasks, filter(const [FilterCondition(field: 'assignee', op: 'is', value: 'Sam')]), fields)), [1]);
    });

    test('AND vs OR within a group; groups join at the top level', () {
      final and = filter(const [
        FilterCondition(field: 'cf:material', op: 'is', value: 'Wood'),
        FilterCondition(field: 'priority', op: 'is', value: 'high'),
      ]);
      expect(ids(applyFilter(tasks, and, fields)), [1]);

      final or = filter(const [
        FilterCondition(field: 'cf:material', op: 'is', value: 'Wood'),
        FilterCondition(field: 'priority', op: 'is', value: 'low'),
      ], join: 'or');
      expect(ids(applyFilter(tasks, or, fields)), [1, 3]);

      // (status is done) OR (weight > 5) as two groups joined by OR.
      const grouped = ViewConfig(join: 'or', groups: [
        FilterGroup(conditions: [FilterCondition(field: 'status', op: 'is', value: 'done')]),
        FilterGroup(conditions: [FilterCondition(field: 'cf:weight', op: 'gt', value: 5)]),
      ]);
      expect(ids(applyFilter(tasks, grouped, fields)), [2, 3]);
    });

    test('unknown fields and empty groups are ignored (deleted-field safety)', () {
      const config = ViewConfig(groups: [
        FilterGroup(conditions: [FilterCondition(field: 'cf:gone', op: 'is', value: 'x')]),
        FilterGroup(conditions: []),
      ]);
      expect(ids(applyFilter(tasks, config, fields)), [1, 2, 3]);
    });
  });

  group('sort', () {
    test('multi-level with direction; empties always last', () {
      const config = ViewConfig(sorts: [
        SortKey(field: 'priority', desc: true), // urgent → low (option order)
        SortKey(field: 'cf:weight'),
      ]);
      expect(ids(applySort(tasks, config, fields)), [2, 1, 3]);

      const byDue = ViewConfig(sorts: [SortKey(field: 'due')]);
      expect(ids(applySort(tasks, byDue, fields)).last, isNot(3)); // 3 has the only date
      expect(ids(applySort(tasks, byDue, fields)).first, 3);
      const byDueDesc = ViewConfig(sorts: [SortKey(field: 'due', desc: true)]);
      expect(ids(applySort(tasks, byDueDesc, fields)).first, 3); // empties still last
    });
  });

  group('group-by', () {
    test('status default keeps all six kanban groups with bare keys', () {
      final groups = computeGroups(tasks, ViewConfig.empty, fields);
      expect(groups.length, 6);
      expect(groups.first.key, 'backlog');
      expect(groups[1].tasks.map((t) => t.id), [1]); // todo
    });

    test('label field: every option gets a group + No-x for empties', () {
      final groups = computeGroups(
          tasks, const ViewConfig(groupBy: 'cf:material'), fields);
      expect(groups.map((g) => g.label).toList(), ['Wood', 'Metal', 'No material']);
      expect(groups[0].color, MndLabelColors.brown); // option colors carried
      expect(groups[2].tasks.map((t) => t.id), [3]);
    });

    test('dynamic field (assignee): present values + No-x', () {
      final groups =
          computeGroups(tasks, const ViewConfig(groupBy: 'assignee'), fields);
      expect(groups.map((g) => g.label).toList(), ['Jo', 'Sam', 'No assignee']);
      expect(groups[0].tasks.single.id, 2);
      expect(groups[1].tasks.single.id, 1);
    });

    test('checkbox groups into checked / not checked', () {
      final groups =
          computeGroups(tasks, const ViewConfig(groupBy: 'cf:ok'), fields);
      expect(groups.first.tasks.single.id, 2);
      expect(groups.last.tasks.length, 2);
    });
  });
}
