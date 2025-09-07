import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_settings.dart';

class SettingsStorage {
  static const String _settingsFileName = 'app_settings.json';

  Future<String> _getSettingsFilePath() async {
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    return '${appDocumentsDir.path}/$_settingsFileName';
  }

  Future<void> saveSettings(AppSettings settings) async {
    try {
      final filePath = await _getSettingsFilePath();
      final file = File(filePath);
      final jsonString = jsonEncode(settings.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      if (kDebugMode) print('Error saving settings: $e');
      rethrow;
    }
  }

  Future<AppSettings?> loadSettings() async {
    try {
      final filePath = await _getSettingsFilePath();
      final file = File(filePath);
      
      if (!await file.exists()) {
        return null; // No settings file exists yet
      }

      final jsonString = await file.readAsString();
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppSettings.fromJson(jsonMap);
    } catch (e) {
      if (kDebugMode) print('Error loading settings: $e');
      return null; // Return null on error, will use defaults
    }
  }

  Future<void> deleteSettings() async {
    try {
      final filePath = await _getSettingsFilePath();
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) print('Error deleting settings: $e');
    }
  }
}