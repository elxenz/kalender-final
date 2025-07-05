// lib/features/settings/data/datasources/settings_local_datasource.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  Future<Map<String, dynamic>> getSettings();
  Future<void> saveSettings(Map<String, dynamic> settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences prefs;

  SettingsLocalDataSourceImpl({required this.prefs});

  @override
  Future<Map<String, dynamic>> getSettings() async {
    return {
      'themeMode': prefs.getString('themeMode') ?? 'system',
      'notificationsEnabled': prefs.getBool('notificationsEnabled') ?? true,
      'defaultReminderMinutes': prefs.getInt('defaultReminderMinutes') ?? 15,
      'language': prefs.getString('language') ?? 'id',
    };
  }

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await prefs.setString('themeMode', settings['themeMode']);
    await prefs.setBool(
        'notificationsEnabled', settings['notificationsEnabled']);
    await prefs.setInt(
        'defaultReminderMinutes', settings['defaultReminderMinutes']);
    await prefs.setString('language', settings['language']);
  }
}

// Helper untuk konversi ThemeMode
extension ThemeModeExtension on ThemeMode {
  String get name {
    switch (this) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }
}

ThemeMode themeModeFromString(String value) {
  switch (value.toLowerCase()) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}
