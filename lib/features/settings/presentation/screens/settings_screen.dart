// lib/features/settings/presentation/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:kalender/features/settings/presentation/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tema',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Mode Tema'),
                        subtitle:
                            Text(_getThemeModeText(settingsProvider.themeMode)),
                        trailing: DropdownButton<ThemeMode>(
                          value: settingsProvider.themeMode,
                          onChanged: (ThemeMode? value) {
                            if (value != null) {
                              settingsProvider.updateThemeMode(value);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('Sistem'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Terang'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Gelap'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notifikasi',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Aktifkan Notifikasi'),
                        subtitle: const Text('Terima pengingat acara'),
                        value: settingsProvider.notificationsEnabled,
                        onChanged: (value) {
                          settingsProvider.updateNotificationsEnabled(value);
                        },
                      ),
                      if (settingsProvider.notificationsEnabled)
                        ListTile(
                          title: const Text('Waktu Pengingat Default'),
                          subtitle: Text(
                              '${settingsProvider.defaultReminderMinutes} menit sebelum acara'),
                          trailing: DropdownButton<int>(
                            value: settingsProvider.defaultReminderMinutes,
                            onChanged: (int? value) {
                              if (value != null) {
                                settingsProvider
                                    .updateDefaultReminderMinutes(value);
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                  value: 5, child: Text('5 menit')),
                              DropdownMenuItem(
                                  value: 10, child: Text('10 menit')),
                              DropdownMenuItem(
                                  value: 15, child: Text('15 menit')),
                              DropdownMenuItem(
                                  value: 30, child: Text('30 menit')),
                              DropdownMenuItem(value: 60, child: Text('1 jam')),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bahasa',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Bahasa Aplikasi'),
                        subtitle:
                            Text(_getLanguageText(settingsProvider.language)),
                        trailing: DropdownButton<String>(
                          value: settingsProvider.language,
                          onChanged: (String? value) {
                            if (value != null) {
                              settingsProvider.updateLanguage(value);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                                value: 'id', child: Text('Indonesia')),
                            DropdownMenuItem(
                                value: 'en', child: Text('English')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getThemeModeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.system:
        return 'Mengikuti sistem';
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
    }
  }

  String _getLanguageText(String languageCode) {
    switch (languageCode) {
      case 'id':
        return 'Indonesia';
      case 'en':
        return 'English';
      default:
        return 'Indonesia';
    }
  }
}
