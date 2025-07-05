// lib/features/calendar/presentation/provider/view_provider.dart
import 'package:flutter/material.dart';

// Enum untuk merepresentasikan semua jenis tampilan yang tersedia
enum CalendarView { jadwal, hari, tigaHari, minggu, bulan }

class ViewProvider extends ChangeNotifier {
  CalendarView _currentView = CalendarView.bulan;

  CalendarView get currentView => _currentView;

  void changeView(CalendarView newView) {
    if (_currentView != newView) {
      _currentView = newView;
      notifyListeners();
    }
  }
}
