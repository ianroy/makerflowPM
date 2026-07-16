import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'src/state/providers.dart';
import 'src/state/session.dart';

void main() {
  runApp(const ProviderScope(child: MakerflowApp()));
}

class MakerflowApp extends ConsumerWidget {
  const MakerflowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    // Gate the router on session restore so a persisted login doesn't flash the
    // login screen on cold start. (Stub mode resolves instantly.)
    final booted = ref.watch(sessionBootstrapProvider);
    if (booted.isLoading) {
      return MaterialApp(
        title: 'MakerFlow PM',
        debugShowCheckedModeBanner: false,
        theme: MakerflowThemeBuilder.light(),
        darkTheme: MakerflowThemeBuilder.dark(),
        themeMode: themeMode,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'MakerFlow PM',
      debugShowCheckedModeBanner: false,
      theme: MakerflowThemeBuilder.light(),
      darkTheme: MakerflowThemeBuilder.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
