import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/features/equipment/equipment_screen.dart';
import 'package:makerflow_flutter/src/features/consumables/consumables_screen.dart';

/// Create write-paths for the operations features, against the in-memory repos.
/// Mirrors the kanban create test: open the FAB dialog, submit, see the row.
Widget _host(Widget screen) => ProviderScope(
      child: MaterialApp(theme: MakerflowThemeBuilder.dark(), home: screen),
    );

void main() {
  testWidgets('New-equipment dialog adds an asset to the list', (tester) async {
    await tester.pumpWidget(_host(const EquipmentScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Glowforge laser'), findsOneWidget); // seeded

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    // "New equipment" is both the FAB label and the dialog title.
    expect(find.text('New equipment'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), 'Vacuum former');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Vacuum former'), findsOneWidget);
  });

  testWidgets('New-consumable dialog validates numbers, then adds stock',
      (tester) async {
    await tester.pumpWidget(_host(const ConsumablesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('New consumable'), findsWidgets); // FAB label + dialog title

    // Name + a non-numeric quantity -> the number validator fires.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'), 'Acrylic sheet');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantity on hand'), 'abc');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Must be a number'), findsOneWidget); // create blocked

    // Fix it and create.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantity on hand'), '25');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Acrylic sheet'), findsOneWidget);
  });

  testWidgets('Tapping an equipment card edits it', (tester) async {
    await tester.pumpWidget(_host(const EquipmentScreen()));
    await tester.pumpAndSettle();

    // Tap a seeded card → edit dialog (pre-filled).
    await tester.tap(find.text('Glowforge laser'));
    await tester.pumpAndSettle();
    expect(find.text('Edit equipment'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Glowforge Pro');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Glowforge Pro'), findsOneWidget);
    expect(find.text('Glowforge laser'), findsNothing);
  });
}
