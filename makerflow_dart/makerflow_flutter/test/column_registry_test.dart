import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/data/view_repository.dart';
import 'package:makerflow_flutter/src/features/tasks/kanban_screen.dart';
import 'package:makerflow_flutter/src/state/providers.dart';

/// fl-8-column-registry: resizable / reorderable / hideable Main-Table
/// columns, persisted through the ViewRepository seam (500ms debounce).
Future<ProviderContainer> _pump(WidgetTester tester,
    {List<Override> overrides = const []}) async {
  tester.view.physicalSize = const Size(1000, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
          theme: MakerflowThemeBuilder.light(), home: const KanbanScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(KanbanScreen)));
}

/// Flush the 500ms save debounce so no timer is pending at test end.
Future<void> _flushSave(WidgetTester tester) =>
    tester.pump(const Duration(milliseconds: 600));

/// The Columns button lives at the far end of the horizontally-scrolling
/// toolbar, past the 1000px test viewport — scroll it into view, then open.
Future<void> _openPopover(WidgetTester tester) async {
  final button = find.byKey(const ValueKey('board-columns'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('registry renders the default columns at their UI-3a widths',
      (tester) async {
    await _pump(tester);
    // One header row per status group, columns in registry order.
    expect(find.text('Item'), findsNWidgets(6));
    expect(find.text('Status'), findsNWidgets(6));
    expect(find.text('Due date'), findsNWidgets(6));
    expect(find.text('Priority'), findsNWidgets(6));
    // Data cells honor the default widths (status = 150).
    expect(tester.getSize(find.byType(StatusLabel).first).width, 150);
  });

  testWidgets('dragging a header boundary resizes the column and persists',
      (tester) async {
    final container = await _pump(tester);
    final before = tester.getSize(find.byType(StatusLabel).first).width;

    await tester.drag(
        find.byKey(const ValueKey('resize:status')).first, const Offset(60, 0));
    await tester.pumpAndSettle();

    final after = tester.getSize(find.byType(StatusLabel).first).width;
    expect(after, greaterThan(before));

    await _flushSave(tester);
    final saved =
        await container.read(viewRepositoryProvider).loadTaskColumns(1);
    expect(saved.firstWhere((p) => p.key == 'status').width, after);
  });

  testWidgets('double-tapping a boundary autofits the column', (tester) async {
    final container = await _pump(tester);

    final handle = find.byKey(const ValueKey('resize:due')).first;
    await tester.tap(handle);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(handle);
    await tester.pumpAndSettle();

    await _flushSave(tester);
    final saved =
        await container.read(viewRepositoryProvider).loadTaskColumns(1);
    final due = saved.firstWhere((p) => p.key == 'due');
    expect(due.width, isNot(104)); // no longer the default
    expect(due.width, inInclusiveRange(80, 420)); // clamped to spec bounds
  });

  testWidgets('dragging a header onto another reorders and persists',
      (tester) async {
    final container = await _pump(tester);

    // Drop Priority onto Status → Priority inserts before Status.
    final from = tester.getCenter(find.text('Priority').first);
    final to = tester.getCenter(find.text('Status').first);
    await tester.drag(find.text('Priority').first, to - from);
    await tester.pumpAndSettle();

    await _flushSave(tester);
    final saved =
        await container.read(viewRepositoryProvider).loadTaskColumns(1);
    expect(saved.map((p) => p.key).toList(), ['priority', 'status', 'due']);
  });

  testWidgets('hiding a column via the popover removes it and persists',
      (tester) async {
    final container = await _pump(tester);

    await _openPopover(tester);
    // Switches follow column order: status, due, priority.
    await tester.tap(find.byType(Switch).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last); // dialog close button
    await tester.pumpAndSettle();

    expect(find.text('Priority'), findsNothing); // header gone from all groups
    expect(find.text('Columns (1 hidden)'), findsOneWidget); // toolbar badge

    await _flushSave(tester);
    final saved =
        await container.read(viewRepositoryProvider).loadTaskColumns(1);
    expect(saved.firstWhere((p) => p.key == 'priority').hidden, isTrue);
  });

  testWidgets('popover carries a11y labels and Up/Down is a full reorder path',
      (tester) async {
    await _pump(tester);
    await _openPopover(tester);

    // AT labels on every control.
    expect(find.bySemanticsLabel('Status visible'), findsOneWidget);
    expect(find.bySemanticsLabel('Due date visible'), findsOneWidget);
    expect(find.bySemanticsLabel('Priority visible'), findsOneWidget);
    expect(find.byTooltip('Move Priority up'), findsOneWidget);
    expect(find.byTooltip('Move Status down'), findsOneWidget);

    // Keyboard/AT reorder: move Due date up → [due, status, priority].
    await tester.tap(find.byTooltip('Move Due date up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();
    await _flushSave(tester);

    final container =
        ProviderScope.containerOf(tester.element(find.byType(KanbanScreen)));
    expect(
        container
            .read(taskColumnPrefsProvider)
            .map((p) => p.key)
            .toList(),
        ['due', 'status', 'priority']);
  });

  testWidgets('a saved layout hydrates on load (order, width, hidden)',
      (tester) async {
    final repo = InMemoryViewRepository();
    await repo.saveTaskColumns(1, const [
      ColumnPref(key: 'priority', width: 120),
      ColumnPref(key: 'due', width: 200),
      ColumnPref(key: 'status', width: 150, hidden: true),
    ]);

    await _pump(tester,
        overrides: [viewRepositoryProvider.overrideWithValue(repo)]);

    expect(find.text('Status'), findsNothing); // hidden column absent
    expect(find.byType(StatusLabel), findsNothing); // ...cells too
    expect(find.text('Columns (1 hidden)'), findsOneWidget);
    // Priority renders before Due date in every header row.
    final pri = tester.getCenter(find.text('Priority').first);
    final due = tester.getCenter(find.text('Due date').first);
    expect(pri.dx, lessThan(due.dx));
  });
}
