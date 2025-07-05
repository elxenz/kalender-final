// lib/features/settings/domain/repositories/settings_repository.dart
import 'package:kalender/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
}
