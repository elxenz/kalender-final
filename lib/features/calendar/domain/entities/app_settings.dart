// lib/features/settings/domain/entities/app_settings.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final int defaultReminderMinutes;
  final String language;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.defaultReminderMinutes = 15,
    this.language = 'id',
  });

  @override
  List<Object?> get props => [
        themeMode,
        notificationsEnabled,
        defaultReminderMinutes,
        language,
      ];

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    int? defaultReminderMinutes,
    String? language,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
      language: language ?? this.language,
    );
  }
}
