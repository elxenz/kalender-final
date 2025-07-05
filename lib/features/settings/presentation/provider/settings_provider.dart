// lib/features/settings/presentation/provider/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:kalender/features/settings/domain/entities/app_settings.dart';
import 'package:kalender/features/settings/domain/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository settingsRepository;

  SettingsProvider(this.settingsRepository);

  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  ThemeMode get themeMode => _settings.themeMode;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  int get defaultReminderMinutes => _settings.defaultReminderMinutes;
  String get language => _settings.language;

  Future<void> loadSettings() async {
    try {
      _settings = await settingsRepository.getSettings();
      notifyListeners();
    } catch (e) {
      // Jika error, gunakan default settings
      _settings = const AppSettings();
      notifyListeners();
    }
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final newSettings = _settings.copyWith(themeMode: themeMode);
    await _saveSettings(newSettings);
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(notificationsEnabled: enabled);
    await _saveSettings(newSettings);
  }

  Future<void> updateDefaultReminderMinutes(int minutes) async {
    final newSettings = _settings.copyWith(defaultReminderMinutes: minutes);
    await _saveSettings(newSettings);
  }

  Future<void> updateLanguage(String language) async {
    final newSettings = _settings.copyWith(language: language);
    await _saveSettings(newSettings);
  }

  Future<void> _saveSettings(AppSettings newSettings) async {
    try {
      await settingsRepository.saveSettings(newSettings);
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      // Handle error jika diperlukan
      debugPrint('Error saving settings: $e');
    }
  }
}