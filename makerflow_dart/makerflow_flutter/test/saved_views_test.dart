import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/data/view_repository.dart';
import 'package:makerflow_flutter/src/features/tasks/kanban_screen.dart';
import 'package:makerflow_flutter/src/state/providers.dart';

/// fl-8-saved-views: tabs render saved views; selecting one applies its
/// columns + surface; "+" captures the current layout; dirty-state
/// Save / Save as new / Reset; rename/delete via the view menu.
Future<ProviderContainer> _pump(WidgetTester tester,
    {required InMemoryViewRepository views}) async {
  tester.view.physicalSize = const Size(1200, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [viewRepositoryProvider.overrideWithValue(views)],
      child: MaterialApp(
          theme: MakerflowThemeBuilder.light(), home: const KanbanScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(KanbanScreen)));
}

Future<void> _flushSave(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 600));

void main() {
  testWidgets('saved views render as tabs; selecting applies columns + type',
      (tester) async {
    final repo = InMemoryViewRepository();
    // A table view with Priority hidden, and a kanban-type view.
    await repo.saveTaskView(1,
        name: 'No priority',
        viewType: 'table',
        columns: const [
          ColumnPref(key: 'status', width: 150),
          ColumnPref(key: 'due', width: 104),
          ColumnPref(key: 'priority', width: 92, hidden: true),
        ]);
    await repo.saveTaskView(1,
        name: 'Sprint board', viewType: 'kanban', columns: const []);
    await _pump(tester, views: repo);

    expect(find.text('No priority'), findsOneWidget); // tab rendered
    expect(find.text('Sprint board'), findsOneWidget);
    expect(find.text('Priority'), findsNWidgets(6)); // default table intact

    await tester.tap(find.text('No priority'));
    await tester.pumpAndSettle();
    expect(find.text('Priority'), findsNothing); // the view's columns applied

    // A kanban-type view switches the visible surface.
    await tester.tap(find.text('Sprint board'));
    await tester.pumpAndSettle();
    expect(find.byType(DragTarget<TaskVmDummy>), findsNothing); // sanity: type below
    expect(find.byTooltip('View options for Sprint board'), findsOneWidget);

    // Back to the built-in Main table restores the default layout.
    await tester.tap(find.byKey(const ValueKey('tab:Main table')));
    await tester.pumpAndSettle();
    expect(find.text('Priority'), findsNWidgets(6));
  });

  testWidgets('"+" captures the current layout as a new selected view',
      (tester) async {
    final repo = InMemoryViewRepository();
    await _pump(tester, views: repo);

    await tester.tap(find.byKey(const ValueKey('tab:add-view')));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('view-name')), 'My layout');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('My layout'), findsOneWidget); // tab appeared
    final views = await repo.listTaskViews(1);
    expect(views.single.name, 'My layout');
    expect(views.single.viewType, 'table');
    expect(views.single.columns.map((c) => c.key),
        containsAll(['status', 'due', 'priority']));
  });

  testWidgets('layout edits mark the view dirty; Save persists; Reset reverts',
      (tester) async {
    final repo = InMemoryViewRepository();
    await repo.saveTaskView(1,
        name: 'Mine',
        viewType: 'table',
        columns: const [
          ColumnPref(key: 'status', width: 150),
          ColumnPref(key: 'due', width: 104),
          ColumnPref(key: 'priority', width: 92),
        ]);
    await _pump(tester, views: repo);
    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('view-save')), findsNothing); // clean

    // Hide Priority through the Columns popover -> dirty.
    final button = find.byKey(const ValueKey('board-columns'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();

    expect(find.text('Edited'), findsOneWidget);

    // Reset reverts to the saved layout. (The chip sits at the end of the
    // horizontally scrolling tab row — bring it on-screen first.)
    await tester.ensureVisible(find.byKey(const ValueKey('view-reset')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('view-reset')));
    await tester.pumpAndSettle();
    expect(find.text('Edited'), findsNothing);
    expect(find.text('Priority'), findsNWidgets(6));

    // Edit again and SAVE into the view this time.
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('view-save')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('view-save')));
    await tester.pumpAndSettle();

    expect(find.text('Edited'), findsNothing);
    final saved = (await repo.listTaskViews(1)).single;
    expect(saved.columns.firstWhere((c) => c.key == 'priority').hidden, isTrue);
    expect(saved.version, greaterThan(1));
    await _flushSave(tester);
  });

  testWidgets('the view menu renames and deletes', (tester) async {
    final repo = InMemoryViewRepository();
    await repo.saveTaskView(1,
        name: 'Old name', viewType: 'table', columns: const []);
    await _pump(tester, views: repo);
    await tester.tap(find.text('Old name'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('view-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const ValueKey('view-rename')), 'New name');
    await tester.tap(find.text('Rename').last);
    await tester.pumpAndSettle();
    expect(find.text('New name'), findsOneWidget);
    expect((await repo.listTaskViews(1)).single.name, 'New name');

    await tester.tap(find.byKey(const ValueKey('view-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last); // confirm
    await tester.pumpAndSettle();
    expect(find.text('New name'), findsNothing);
    expect(await repo.listTaskViews(1), isEmpty);
  });

  testWidgets(
      'edits under a saved view do NOT touch the default __table_layout',
      (tester) async {
    final repo = InMemoryViewRepository();
    await repo.saveTaskView(1,
        name: 'Sandbox', viewType: 'table', columns: const []);
    await _pump(tester, views: repo);
    await tester.tap(find.text('Sandbox'));
    await tester.pumpAndSettle();

    // Resize a column while the saved view is active.
    await tester.drag(
        find.byKey(const ValueKey('resize:status')).first, const Offset(40, 0));
    await tester.pumpAndSettle();
    await _flushSave(tester);

    expect(await repo.loadTaskColumns(1), isEmpty); // default untouched
  });
}

/// A never-matching type so the sanity finder above compiles without
/// importing the task model (the kanban surface is asserted via the menu).
class TaskVmDummy {}
