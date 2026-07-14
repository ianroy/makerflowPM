import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/features/projects/projects_screen.dart';
import 'package:makerflow_flutter/src/features/tasks/kanban_screen.dart';

Widget _host(Widget screen) => ProviderScope(
      child: MaterialApp(theme: MakerflowThemeBuilder.dark(), home: screen),
    );

void main() {
  testWidgets('New-project dialog creates a project in the list', (tester) async {
    await tester.pumpWidget(_host(const ProjectsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Fall capstone cohort'), findsOneWidget); // seeded

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('New project'), findsWidgets); // FAB label + dialog title

    await tester.enterText(find.byType(TextFormField), 'Robotics summer camp');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Robotics summer camp'), findsOneWidget);
  });

  testWidgets('Tapping a project card edits it', (tester) async {
    await tester.pumpWidget(_host(const ProjectsScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shop safety refresh'));
    await tester.pumpAndSettle();
    expect(find.text('Edit project'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Shop safety refresh v2');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Shop safety refresh v2'), findsOneWidget);
    expect(find.text('Shop safety refresh'), findsNothing);
  });

  testWidgets('Project filter narrows the kanban board', (tester) async {
    await tester.pumpWidget(_host(const KanbanScreen()));
    await tester.pumpAndSettle();
    // Default view is the Main table (UI-3); this test targets the kanban.
    await tester.tap(find.byKey(const ValueKey('tab:Kanban')));
    await tester.pumpAndSettle();
    // Unfiltered: tasks from every project are on the board.
    expect(find.text('Laser cutter monthly PM'), findsOneWidget); // no project
    expect(find.text('Onboard fall student cohort'), findsOneWidget); // project 1

    // Filter to "Fall capstone cohort" (project 1).
    await tester.tap(find.text('All projects'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fall capstone cohort').last);
    await tester.pumpAndSettle();

    expect(find.text('Onboard fall student cohort'), findsOneWidget); // kept
    expect(find.text('Laser cutter monthly PM'), findsNothing); // filtered out
  });
}
