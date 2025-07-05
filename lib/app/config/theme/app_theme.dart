// lib/app/config/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Palet Warna Kustom Anda
  static const Color primaryDark = Color(0xFF301E67);
  static const Color primaryLight = Color(0xFF5B8FB9);
  static const Color accent = Color(0xFFB6EADA);
  static const Color backgroundDark = Color(0xFF03001C);
  static const Color backgroundLight = Color(0xFFFDFDFD);

  // --- Konfigurasi Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryLight, // Biru terang untuk aksi utama
      secondary: primaryDark, // Ungu gelap sebagai aksen
      background: backgroundLight,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Color(0xFF333333),
      onSurface: Color(0xFF333333),
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryDark,
      elevation: 1,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardTheme(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
    ),
  );

  // --- Konfigurasi Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryLight, // Biru terang untuk aksi utama
      secondary: accent, // Mint sebagai aksen cerah
      background: backgroundDark,
      surface: primaryDark, // Ungu gelap sebagai latar belakang card
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Color(0xFFEAEAEA),
      onSurface: Color(0xFFEAEAEA),
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      color: primaryDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.black,
    ),
  );
}
