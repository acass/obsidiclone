import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../services/export_service.dart';

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Container(
          height: 50,
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildTab(
                    context,
                    'Editor',
                    Icons.edit,
                    appState.currentView == AppView.editor,
                    () => appState.setView(AppView.editor),
                  ),
                  _buildTab(
                    context,
                    'Graph view',
                    Icons.account_tree,
                    appState.currentView == AppView.graphView,
                    () => appState.setView(AppView.graphView),
                  ),
                  _buildTab(
                    context,
                    'Export & Upload',
                    Icons.cloud_upload,
                    false,
                    () async => await ExportService.exportAndZipNotes(appState),
                  ),
                ],
              ),
              _buildTab(
                context,
                'Settings',
                Icons.settings,
                appState.currentView == AppView.settings,
                () => appState.setView(AppView.settings),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(
    BuildContext context,
    String title,
    IconData icon,
    bool isActive,
    Function() onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}