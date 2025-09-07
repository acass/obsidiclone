import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import 'welcome_screen.dart';
import 'editor_view.dart';
import 'graph_view.dart';
import 'settings_view.dart';

class ContentArea extends StatelessWidget {
  const ContentArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        switch (appState.currentView) {
          case AppView.editor:
            return appState.selectedNote != null
                ? EditorView(note: appState.selectedNote!)
                : const WelcomeScreen();
          case AppView.graphView:
            return const GraphView();
          case AppView.settings:
            return const SettingsView();
        }
      },
    );
  }
}