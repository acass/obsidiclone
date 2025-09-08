import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'models/app_state.dart';
import 'models/app_settings.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ObsidiCloneApp());
}

class ObsidiCloneApp extends StatelessWidget {
  const ObsidiCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final appState = AppState();
        appState.loadPersistedNotes();
        appState.loadPersistedSettings();
        return appState;
      },
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          final isDarkTheme = appState.appSettings.theme == AppTheme.dark;
          
          return MaterialApp(
            title: 'ObsidiClone',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
            ],
            theme: isDarkTheme 
              ? ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: const Color(0xFF1a1a1a),
                  colorScheme: const ColorScheme.dark(
                    primary: Color.fromARGB(255, 228, 42, 42),
                    secondary: Color.fromARGB(255, 223, 84, 84),
                    surface: Color(0xFF2a2a2a),
                  ),
                  cardColor: const Color(0xFF2a2a2a),
                  dividerColor: const Color(0xFF404040),
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(color: Colors.white),
                    bodyMedium: TextStyle(color: Colors.white70),
                    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    titleMedium: TextStyle(color: Colors.white70),
                  ),
                )
              : ThemeData.light().copyWith(
                  scaffoldBackgroundColor: const Color(0xFFf5f5f5),
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFd32f2f),
                    secondary: Color(0xFFd32f2f),
                    surface: Color(0xFFffffff),
                  ),
                  cardColor: const Color(0xFFffffff),
                  dividerColor: const Color(0xFFe0e0e0),
                  textTheme: const TextTheme(
                    bodyLarge: TextStyle(color: Colors.black87),
                    bodyMedium: TextStyle(color: Colors.black54),
                    titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    titleMedium: TextStyle(color: Colors.black54),
                  ),
                ),
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
