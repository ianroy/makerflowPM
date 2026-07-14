import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'package:makerflow_flutter/src/data/preference_repository.dart';
import 'package:makerflow_flutter/src/state/providers.dart';
import 'package:makerflow_flutter/src/state/session.dart';

/// fl-8: theme + sidebar persistence through the preference repository.
Future<ProviderContainer> _pumpApp(WidgetTester tester, PreferenceRepository repo) async {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    overrides: [preferenceRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  await container.read(sessionProvider.notifier).signIn('t@t', 'pw');
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
  testWidgets('saved prefs hydrate the shell (theme + sidebar restored)', (tester) async {
    final repo = InMemoryPreferenceRepository();
    await repo.save(const PrefsVm(theme: 'dark', sidebarCollapsed: true));

    final container = await _pumpApp(tester, repo);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(container.read(sidebarCollapsedProvider), isTrue);
    expect(find.byKey(const ValueKey('nav:Home')), findsNothing); // collapsed
  });

  testWidgets('theme flip + sidebar collapse persist to the repository', (tester) async {
    final repo = InMemoryPreferenceRepository();
    await _pumpApp(tester, repo);

    await tester.tap(find.byTooltip('Account menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark theme'));
    await tester.pumpAndSettle();
    expect((await repo.load()).theme, 'dark');

    await tester.tap(find.byTooltip('Collapse navigation'));
    await tester.pumpAndSettle();
    expect((await repo.load()).sidebarCollapsed, isTrue);
  });
}
