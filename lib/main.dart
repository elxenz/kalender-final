// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kalender/app/app.dart';
import 'package:kalender/core/utils/notification_helper.dart';
import 'package:kalender/features/calendar/data/datasources/event_local_datasource.dart';
import 'package:kalender/features/calendar/data/repositories/event_repository_impl.dart';
import 'package:kalender/features/calendar/presentation/provider/event_provider.dart';
import 'package:kalender/features/calendar/presentation/provider/view_provider.dart'; // Impor baru
import 'package:kalender/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:kalender/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:kalender/features/settings/presentation/provider/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kalender/features/todo/presentation/provider/todo_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final prefs = await SharedPreferences.getInstance();
  final settingsLocalDataSource = SettingsLocalDataSourceImpl(prefs: prefs);
  final settingsRepository =
      SettingsRepositoryImpl(localDataSource: settingsLocalDataSource);
  final eventRepository =
      EventRepositoryImpl(localDataSource: EventLocalDataSourceImpl());

  await NotificationHelper().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsRepository)..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              EventProvider(eventRepository: eventRepository)..getEvents(),
        ),
        // --- PROVIDER BARU DITAMBAHKAN DI SINI ---
        ChangeNotifierProvider(
          create: (_) => ViewProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TodoProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
