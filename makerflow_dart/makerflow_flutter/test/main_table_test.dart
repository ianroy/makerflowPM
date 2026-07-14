import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/features/tasks/kanban_screen.dart';

/// UI-3 Main Table tests (the default Tasks view), on the in-memory repo.
Future<void> _pump(WidgetTester tester, {Size size = const Size(1000, 1400)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(theme: MakerflowThemeBuilder.light(), home: const KanbanScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders groups with counts, rows, and the board battery', (tester) async {
    await _pump(tester);
    expect(find.text('Backlog'), findsWidgets); // group header
    expect(find.text('1 item'), findsNWidgets(6)); // one seeded task per group
    expect(find.text('Restock 3mm plywood'), findsOneWidget); // a row
    expect(find.text('Jul 18'), findsOneWidget); // seeded dueAt renders
    expect(find.textContaining('% done'), findsOneWidget); // battery summary
  });

  testWidgets('status cell opens the picker and moves the task between groups', (tester) async {
    await _pump(tester);
    // The Backlog group holds "Restock 3mm plywood"; its status cell shows "Backlog".
    // Tap the row's status cell (the StatusLabel inside the row, not the header).
    await tester.tap(find.byType(StatusLabel).first);
    await tester.pumpAndSettle();
    expect(find.text('Edit Labels'), findsNothing); // (label editing is later)
    await tester.tap(find.text('Done').last); // pick Done in the picker
    await tester.pumpAndSettle();

    // The task moved to the Done group: Backlog now empty, Done has 2.
    expect(find.text('0 items'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget);
  });

  testWidgets('ghost row adds an item into its group and chains focus', (tester) async {
    await _pump(tester);
    final ghost = find.byKey(const ValueKey('add-item:todo'));
    await tester.enterText(ghost, 'Grease the CNC rails');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Grease the CNC rails'), findsOneWidget);
    expect(find.text('2 items'), findsOneWidget); // To do grew
    // Chaining: the ghost field is cleared and still there for the next entry.
    expect(tester.widget<TextField>(ghost).controller!.text, isEmpty);
  });

  testWidgets('collapsing a group hides its rows', (tester) async {
    await _pump(tester);
    expect(find.text('Restock 3mm plywood'), findsOneWidget);
    await tester.tap(find.byTooltip('Collapse Backlog'));
    await tester.pumpAndSettle();
    expect(find.text('Restock 3mm plywood'), findsNothing);
    await tester.tap(find.byTooltip('Expand Backlog'));
    await tester.pumpAndSettle();
    expect(find.text('Restock 3mm plywood'), findsOneWidget);
  });

  testWidgets('due-date cell opens the picker and sets a date', (tester) async {
    await _pump(tester);
    // "Restock 3mm plywood" (backlog) has no due date → its cell shows —.
    await tester.tap(find.text('—').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK')); // accept the initial (today) selection
    await tester.pumpAndSettle();
    expect(find.text('—'), findsNWidgets(3)); // one fewer dash than the seeded 4
  });
}
