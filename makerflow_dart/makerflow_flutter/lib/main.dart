import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:makerflow_design/makerflow_design.dart';

import 'src/router.dart';
import 'src/state/providers.dart';

void main() {
  runApp(const ProviderScope(child: MakerflowApp()));
}

class MakerflowApp extends ConsumerWidget {
  const MakerflowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
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
