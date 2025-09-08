import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../models/app_settings.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final settings = appState.appSettings;
        
        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 32),
                _buildSettingsSection(
                  context,
                  'General',
                  [
                    _buildSettingItem(
                      context,
                      'Theme',
                      settings.themeDisplayName,
                      Icons.palette,
                      () => _showThemeDialog(context, appState),
                    ),
                    _buildSettingItem(
                      context,
                      'Auto-save',
                      settings.autoSaveDisplayName,
                      Icons.save,
                      () => _showAutoSaveDialog(context, appState),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingsSection(
                  context,
                  'Editor',
                  [
                    _buildSettingItem(
                      context,
                      'Font Size',
                      settings.fontSizeDisplayName,
                      Icons.text_fields,
                      () => _showFontSizeDialog(context, appState),
                    ),
                    _buildSettingItem(
                      context,
                      'Show Preview',
                      settings.showPreviewDisplayName,
                      Icons.preview,
                      () => _showPreviewDialog(context, appState),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Theme',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Radio<AppTheme>(
                value: AppTheme.light,
                groupValue: appState.appSettings.theme,
                onChanged: (value) {
                  if (value != null) {
                    appState.updateTheme(value);
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text('Light'),
              onTap: () {
                appState.updateTheme(AppTheme.light);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Radio<AppTheme>(
                value: AppTheme.dark,
                groupValue: appState.appSettings.theme,
                onChanged: (value) {
                  if (value != null) {
                    appState.updateTheme(value);
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text('Dark'),
              onTap: () {
                appState.updateTheme(AppTheme.dark);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoSaveDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Auto-save',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Radio<bool>(
                value: true,
                groupValue: appState.appSettings.autoSave,
                onChanged: (value) {
                  if (value != null) {
                    appState.updateAutoSave(value);
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text('Enabled'),
              onTap: () {
                appState.updateAutoSave(true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Radio<bool>(
                value: false,
                groupValue: appState.appSettings.autoSave,
                onChanged: (value) {
                  if (value != null) {
                    appState.updateAutoSave(value);
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text('Disabled'),
              onTap: () {
                appState.updateAutoSave(false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Font Size',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            double currentSize = appState.appSettings.fontSize;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currentSize.toInt()}px',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: currentSize,
                  min: 8.0,
                  max: 24.0,
                  divisions: 16,
                  onChanged: (value) {
                    setState(() {
                      currentSize = value;
                    });
                  },
                  onChangeEnd: (value) {
                    appState.updateFontSize(value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Show Preview',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Radio<bool>(
                value: true,
                groupValue: appState.appSettings.showPreview,
                onChanged: (value) {
                  if (value != null) {
                    appState.updateShowPreview(value);
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text('Enabled'),
              onTap: () {
                appState.updateShowPreview(true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Radio<bool>(
                value: false,
                groupValue: appState.appSettings.showPreview,
                onChanged: (value) {
                  if (value != null) {
                    appState.updateShowPreview(value);
                    Navigator.pop(context);
                  }
                },
              ),
              title: Text('Disabled'),
              onTap: () {
                appState.updateShowPreview(false);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}