import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/data/field_models.dart';
import 'package:makerflow_flutter/src/data/field_repository.dart';
import 'package:makerflow_flutter/src/data/view_repository.dart';
import 'package:makerflow_flutter/src/features/tasks/kanban_screen.dart';
import 'package:makerflow_flutter/src/state/providers.dart';

/// fl-8-filter-sort-group (widget layer): the filter builder narrows rows,
/// header clicks toggle sort, group-by-any-field regroups the table, and
/// saved views restore their filter/sort/group config.
Future<ProviderContainer> _pump(WidgetTester tester,
    {FieldRepository? fields, InMemoryViewRepository? views}) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (fields != null) fieldRepositoryProvider.overrideWithValue(fields),
        if (views != null) viewRepositoryProvider.overrideWithValue(views),
      ],
      child: MaterialApp(
          theme: MakerflowThemeBuilder.light(), home: const KanbanScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(KanbanScreen)));
}

Future<void> _tapToolbar(WidgetTester tester, String key) async {
  final button = find.byKey(ValueKey(key));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<InMemoryFieldRepository> _materialField() async {
  final repo = InMemoryFieldRepository();
  await repo.save(
      1,
      const FieldConfigVm(key: 'material', label: 'Material', fieldType: 'label', options: [
        FieldOption('Wood', color: MndLabelColors.brown),
        FieldOption('Metal', color: MndLabelColors.winter),
      ]));
  return repo;
}

void main() {
  testWidgets('the filter builder narrows rows and badges the toolbar',
      (tester) async {
    await _pump(tester);
    expect(find.text('Restock 3mm plywood'), findsOneWidget);

    await _tapToolbar(tester, 'board-filter');
    await tester.tap(find.byKey(const ValueKey('filter-add:0')));
    await tester.pumpAndSettle();
    // Default condition: Item contains <value>.
    await tester.enterText(find.byKey(const ValueKey('filter-value')), 'laser');
    await tester.tap(find.byKey(const ValueKey('filter-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Laser cutter monthly PM'), findsOneWidget);
    expect(find.text('Restock 3mm plywood'), findsNothing);
    expect(find.text('Filter (1)'), findsOneWidget);

    // Clear restores everything.
    await _tapToolbar(tester, 'board-filter');
    await tester.tap(find.byKey(const ValueKey('filter-clear')));
    await tester.pumpAndSettle();
    expect(find.text('Restock 3mm plywood'), findsOneWidget);
  });

  testWidgets('column-header clicks cycle sort asc → desc → off',
      (tester) async {
    final container = await _pump(tester);

    await tester.tap(find.text('Priority').first);
    await tester.pumpAndSettle();
    expect(container.read(taskViewConfigProvider).sorts.single.field, 'priority');
    expect(container.read(taskViewConfigProvider).sorts.single.desc, isFalse);
    expect(find.textContaining('Priority ▲'), findsWidgets); // header marker

    await tester.tap(find.textContaining('Priority ▲').first);
    await tester.pumpAndSettle();
    expect(container.read(taskViewConfigProvider).sorts.single.desc, isTrue);

    await tester.tap(find.textContaining('Priority ▼').first);
    await tester.pumpAndSettle();
    expect(container.read(taskViewConfigProvider).sorts, isEmpty);
  });

  testWidgets('group-by a custom label field regroups; add-item carries the value',
      (tester) async {
    final container = await _pump(tester, fields: await _materialField());

    await _tapToolbar(tester, 'board-group');
    await tester.tap(find.text('Material').last); // dialog option, not headers
    await tester.pumpAndSettle();

    // All options become groups; valueless tasks land in "No material".
    expect(find.text('Wood'), findsOneWidget);
    expect(find.text('Metal'), findsOneWidget);
    expect(find.text('No material'), findsOneWidget);

    // The ghost row of the Wood group creates a task WITH material=Wood.
    await tester.enterText(
        find.byKey(const ValueKey('add-item:cf:material:Wood')), 'Shelf brackets');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final tasks = await container.read(taskRepositoryProvider).list(1);
    final created = tasks.firstWhere((t) => t.title == 'Shelf brackets');
    expect(created.customFields['material'], 'Wood');
    expect(created.status, 'todo');
  });

  testWidgets('group-by assignee groups people correctly', (tester) async {
    await _pump(tester);

    await _tapToolbar(tester, 'board-group');
    await tester.tap(find.text('Assignee'));
    await tester.pumpAndSettle();

    // Seeded board: Sam ×2, Jo ×2, Pat ×2 — alphabetical groups.
    expect(find.text('Jo'), findsOneWidget);
    expect(find.text('Pat'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('2 items'), findsNWidgets(3));
  });

  testWidgets('saved views persist and restore their filter config',
      (tester) async {
    final views = InMemoryViewRepository();
    await _pump(tester, views: views);

    // Build a filter, then capture it as a saved view.
    await _tapToolbar(tester, 'board-filter');
    await tester.tap(find.byKey(const ValueKey('filter-add:0')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('filter-value')), 'laser');
    await tester.tap(find.byKey(const ValueKey('filter-apply')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab:add-view')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('view-name')), 'Lasers');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect((await views.listTaskViews(1)).single.config.conditionCount, 1);

    // Built-in tab clears the filter; the saved tab restores it.
    await tester.tap(find.byKey(const ValueKey('tab:Main table')));
    await tester.pumpAndSettle();
    expect(find.text('Restock 3mm plywood'), findsOneWidget);
    await tester.tap(find.text('Lasers'));
    await tester.pumpAndSettle();
    expect(find.text('Restock 3mm plywood'), findsNothing);
    expect(find.text('Filter (1)'), findsOneWidget);
  });
}
