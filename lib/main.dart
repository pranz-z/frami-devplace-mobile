import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/sketch_theme.dart';
import 'core/providers/app_providers.dart';
import 'core/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const DeveloperWorkplaceApp(),
    ),
  );
}

class DeveloperWorkplaceApp extends ConsumerWidget {
  const DeveloperWorkplaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeStringProvider);

    ThemeMode mode;
    switch (themeMode) {
      case 'dark':
        mode = ThemeMode.dark;
        break;
      case 'light':
        mode = ThemeMode.light;
        break;
      default:
        mode = ThemeMode.system;
    }

    return MaterialApp.router(
      title: 'Developer Workplace',
      debugShowCheckedModeBanner: false,
      theme: AppSketchTheme.lightTheme,
      darkTheme: AppSketchTheme.darkTheme,
      themeMode: mode,
      routerConfig: router,
    );
  }
}
