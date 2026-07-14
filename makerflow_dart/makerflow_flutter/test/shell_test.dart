import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/state/providers.dart';
import 'package:makerflow_flutter/src/state/session.dart';

/// UI-1 shell tests: run the REAL router (stub sign-in) at a wide viewport so
/// the sidebar renders, then exercise nav, boards-from-projects, collapse,
/// and the avatar theme menu.
Future<ProviderContainer> _pumpApp(WidgetTester tester, {Size size = const Size(1280, 800)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  await container.read(sessionProvider.notifier).signIn('t@makerflow.local', 'pw'); // stub mode: instant
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: Consumer(builder: (context, ref, _) {
      return MaterialApp.router(
        theme: MakerflowThemeBuilder.light(),
        darkTheme: MakerflowThemeBuilder.dark(),
        themeMode: ref.watch(themeModeProvider),
        routerConfig: ref.watch(routerProvider),
      );
    }),
  ));
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('sidebar renders workspace tile + destinations on the dashboard', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Brandeis MakerLab'), findsWidgets); // workspace tile (stub org)
    expect(find.byKey(const ValueKey('nav:Home')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav:All tasks')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav:Equipment')), findsOneWidget);
    expect(find.byKey(const ValueKey('nav:Trash')), findsOneWidget);
  });

  testWidgets('sidebar lists a board per project; tapping filters the tasks board', (tester) async {
    await _pumpApp(tester);
    final projectBoard = find.byKey(const ValueKey('nav:Fall capstone cohort'));
    expect(projectBoard, findsOneWidget);

    await tester.tap(projectBoard);
    await tester.pumpAndSettle();

    // /tasks with the project filter applied: project-1 tasks only.
    expect(find.text('Onboard fall student cohort'), findsOneWidget);
    expect(find.text('Laser cutter monthly PM'), findsNothing);
  });

  testWidgets('sidebar navigates to Equipment', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('nav:Equipment')));
    await tester.pumpAndSettle();
    expect(find.text('Glowforge laser'), findsOneWidget);
  });

  testWidgets('collapse toggle hides the sidebar and persists via provider', (tester) async {
    final container = await _pumpApp(tester);
    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();
    expect(container.read(sidebarCollapsedProvider), isTrue);
    expect(find.byKey(const ValueKey('nav:Home')), findsNothing);

    await tester.tap(find.byTooltip('Expand navigation'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('nav:Home')), findsOneWidget);
  });

  testWidgets('avatar menu flips the theme', (tester) async {
    final container = await _pumpApp(tester);
    expect(container.read(themeModeProvider), ThemeMode.light);
    await tester.tap(find.byTooltip('Account menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark theme'));
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('narrow viewport swaps the sidebar for a drawer', (tester) async {
    await _pumpApp(tester, size: const Size(500, 800));
    expect(find.byKey(const ValueKey('nav:Home')), findsNothing); // no inline sidebar
    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('nav:Home')), findsOneWidget); // in the drawer
  });
}
