import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/features/tasks/kanban_screen.dart';
import 'package:makerflow_flutter/src/state/providers.dart';

/// fl-8-column-summaries: footer aggregation picker, per-group footers +
/// board grand total, battery text equivalents, and persistence via the
/// column-prefs pipeline.
Future<ProviderContainer> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
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
  testWidgets(
      'the grand-total footer picks an aggregation; per-group footers follow; '
      'the choice persists with the layout', (tester) async {
    final container = await _pump(tester);

    // Only the grand total renders before any summary is chosen.
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('6 filled'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Summary for Priority'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Summary for Priority'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filled count'));
    await tester.pumpAndSettle();

    // Grand total counts all six; each status group footer counts its one.
    expect(find.text('6 filled'), findsOneWidget);
    expect(find.text('1 filled'), findsNWidgets(6));

    // The choice rides ColumnPref persistence (default __table_layout).
    await _flushSave(tester);
    final saved =
        await container.read(viewRepositoryProvider).loadTaskColumns(1);
    expect(saved.firstWhere((p) => p.key == 'priority').summary, 'count');

    // Clearing removes the group footers again.
    await tester.tap(find.byTooltip('Summary for Priority').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('None'));
    await tester.pumpAndSettle();
    expect(find.text('1 filled'), findsNothing);
    await _flushSave(tester);
  });

  testWidgets('the status battery renders with a text equivalent (AT)',
      (tester) async {
    await _pump(tester);

    await tester.ensureVisible(find.byTooltip('Summary for Status'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Summary for Status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Battery'));
    await tester.pumpAndSettle();

    // Seeded board: 1 done of 6. The cell's semantics carries the numbers.
    expect(
        find.bySemanticsLabel(
            RegExp(r'Status Battery: 1 of 6 done \(17%\)\. Change summary')),
        findsOneWidget);
    await _flushSave(tester);
  });

  testWidgets('the Columns popover offers the same summary picker (AT path)',
      (tester) async {
    final container = await _pump(tester);

    final button = find.byKey(const ValueKey('board-columns'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    // Both the footer cell and the popover row carry this tooltip — the
    // dialog's copy renders later in the tree.
    await tester.tap(find.byTooltip('Summary for Due date').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Date range'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();

    expect(find.text('Jul 18 – Jul 21'), findsOneWidget); // grand total range
    await _flushSave(tester);
    final saved =
        await container.read(viewRepositoryProvider).loadTaskColumns(1);
    expect(saved.firstWhere((p) => p.key == 'due').summary, 'range');
  });
}
