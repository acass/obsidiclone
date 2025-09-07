import 'package:flutter/material.dart';

enum AppTheme {
  light,
  dark,
}

class AppSettings extends ChangeNotifier {
  AppTheme _theme = AppTheme.dark;
  bool _autoSave = true;
  double _fontSize = 14.0;
  bool _showPreview = true;

  AppTheme get theme => _theme;
  bool get autoSave => _autoSave;
  double get fontSize => _fontSize;
  bool get showPreview => _showPreview;

  String get themeDisplayName {
    switch (_theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
    }
  }

  String get autoSaveDisplayName => _autoSave ? 'Enabled' : 'Disabled';
  String get fontSizeDisplayName => '${_fontSize.toInt()}px';
  String get showPreviewDisplayName => _showPreview ? 'Enabled' : 'Disabled';

  void setTheme(AppTheme theme) {
    _theme = theme;
    notifyListeners();
  }

  void setAutoSave(bool autoSave) {
    _autoSave = autoSave;
    notifyListeners();
  }

  void setFontSize(double fontSize) {
    _fontSize = fontSize;
    notifyListeners();
  }

  void setShowPreview(bool showPreview) {
    _showPreview = showPreview;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': _theme.index,
      'autoSave': _autoSave,
      'fontSize': _fontSize,
      'showPreview': _showPreview,
    };
  }

  AppSettings();
  
  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final settings = AppSettings();
    settings._theme = AppTheme.values[json['theme'] ?? AppTheme.dark.index];
    settings._autoSave = json['autoSave'] ?? true;
    settings._fontSize = (json['fontSize'] ?? 14.0).toDouble();
    settings._showPreview = json['showPreview'] ?? true;
    return settings;
  }
}