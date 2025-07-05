// lib/app/config/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Impor package animasi
import 'package:kalender/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:kalender/features/settings/presentation/screens/settings_screen.dart';
import 'package:kalender/features/todo/presentation/screens/todo_list_screen.dart';

class AppRouter {
  static const String calendar = '/';
  static const String settings = '/settings';
  static const String todoList = '/todo-list';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case calendar:
        return _buildAnimatedRoute(const CalendarScreen());
      case settings:
        return _buildAnimatedRoute(const SettingsScreen());
      case todoList:
        return _buildAnimatedRoute(const TodoListScreen());
      default:
        return _buildAnimatedRoute(
          Scaffold(
            body: Center(
              child: Text('Halaman tidak ditemukan: ${routeSettings.name}'),
            ),
          ),
        );
    }
  }

  // Helper untuk membuat transisi halaman dengan animasi
  static PageRouteBuilder _buildAnimatedRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Efek geser dari kanan ke kiri
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      transitionDuration: 300.ms, // Durasi animasi
    );
  }
}
