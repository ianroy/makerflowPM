import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/features/tasks/kanban_screen.dart';

// Smoke test: the kanban renders its columns and the seeded tasks from the
// in-memory repository. Expands as the vertical slice grows.
void main() {
  testWidgets('Kanban renders columns and a seeded task', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MakerflowThemeBuilder.dark(),
          home: const KanbanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Unique seeded task titles prove the board hydrated from the repository.
    expect(find.text('Laser cutter monthly PM'), findsOneWidget);
    expect(find.text('Onboard fall student cohort'), findsOneWidget);
    // Column labels also appear on status badges, so there can be >1 — assert
    // the board rendered its columns without pinning an exact count.
    expect(find.text('In progress'), findsWidgets);
    expect(find.text('Done'), findsWidgets);
  });

  testWidgets('New-task dialog creates a task and it appears on the board',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MakerflowThemeBuilder.dark(),
          home: const KanbanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open the dialog from the FAB.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('New task'), findsWidgets); // dialog title

    // Submitting empty surfaces the required-field error (no task created).
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Title is required'), findsOneWidget);

    // Fill the title and create.
    await tester.enterText(
        find.byType(TextFormField), 'Calibrate the 3D printer');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // Dialog closed and the new card is on the board.
    expect(find.text('Title is required'), findsNothing);
    expect(find.text('Calibrate the 3D printer'), findsOneWidget);
  });

  testWidgets('Tapping a card edits it and the board reflects the change',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MakerflowThemeBuilder.dark(),
          home: const KanbanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap a seeded card to open the edit dialog (pre-filled).
    await tester.tap(find.text('Restock 3mm plywood'));
    await tester.pumpAndSettle();
    expect(find.text('Edit task'), findsOneWidget);

    // Change the title and save.
    await tester.enterText(
        find.byType(TextFormField), 'Restock 6mm plywood');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Board shows the edited title; the old one is gone.
    expect(find.text('Restock 6mm plywood'), findsOneWidget);
    expect(find.text('Restock 3mm plywood'), findsNothing);
  });

  testWidgets('Edit dialog deletes a task off the board', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MakerflowThemeBuilder.dark(),
          home: const KanbanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Restock 3mm plywood'), findsOneWidget); // backlog (leftmost, visible)

    await tester.tap(find.text('Restock 3mm plywood')); // tap → edit dialog
    await tester.pumpAndSettle();
    expect(find.text('Edit task'), findsOneWidget);

    await tester.tap(find.text('Delete')); // dialog's Delete → confirm
    await tester.pumpAndSettle();
    expect(find.text('Delete task?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete')); // confirm
    await tester.pumpAndSettle();

    expect(find.text('Restock 3mm plywood'), findsNothing); // off the board
  });

  testWidgets('Toggling to List view shows tasks grouped by status', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MakerflowThemeBuilder.dark(),
          home: const KanbanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('List')); // SegmentedButton segment
    await tester.pumpAndSettle();

    expect(find.text('Laser cutter monthly PM'), findsOneWidget); // a seeded task
    expect(find.text('To do'), findsWidgets); // a status group header
  });
}
