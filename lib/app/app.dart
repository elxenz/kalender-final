// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Impor baru
import 'package:kalender/app/config/router/app_router.dart';
import 'package:kalender/app/config/theme/app_theme.dart';
import 'package:kalender/features/settings/presentation/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Kalender',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,

          // --- KONFIGURASI LOKALISASI DITAMBAHKAN DI SINI ---
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('id', 'ID'), // Bahasa Indonesia
            Locale('en', 'US'), // Bahasa Inggris sebagai fallback
          ],
          locale: Locale(settings.language), // Atur locale dari provider
          // ---------------------------------------------------

          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: AppRouter.calendar,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
