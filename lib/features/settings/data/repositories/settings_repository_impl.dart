// lib/features/settings/data/repositories/settings_repository_impl.dart
import 'package:kalender/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:kalender/features/settings/domain/entities/app_settings.dart';
import 'package:kalender/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<AppSettings> getSettings() async {
    final data = await localDataSource.getSettings();
    return AppSettings(
      themeMode: themeModeFromString(data['themeMode']),
      notificationsEnabled: data['notificationsEnabled'],
      defaultReminderMinutes: data['defaultReminderMinutes'],
      language: data['language'],
    );
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final data = {
      'themeMode': settings.themeMode.name,
      'notificationsEnabled': settings.notificationsEnabled,
      'defaultReminderMinutes': settings.defaultReminderMinutes,
      'language': settings.language,
    };
    await localDataSource.saveSettings(data);
  }
}
