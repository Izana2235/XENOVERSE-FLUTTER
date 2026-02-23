import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'models/app_state.dart' as app_state;
import 'theme/app_theme.dart';
import 'screens/home_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Determine the theme based on app state
    ThemeData themeData;
    bool isDarkMode = false;

    if (appState.themeMode == app_state.AppThemeMode.system) {
      // Follow system preference
      isDarkMode =
          MediaQuery.of(context).platformBrightness == Brightness.dark;
      themeData =
          isDarkMode ? AppTheme.darkTheme() : AppTheme.lightTheme();
    } else if (appState.themeMode == app_state.AppThemeMode.dark) {
      isDarkMode = true;
      themeData = AppTheme.darkTheme();
    } else {
      isDarkMode = false;
      themeData = AppTheme.lightTheme();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XENOVERSE',
      theme: themeData,
      home: const HomePage(),
    );
  }
}

