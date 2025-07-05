// lib/features/calendar/presentation/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:kalender/app/config/router/app_router.dart';
import 'package:kalender/features/calendar/presentation/provider/event_provider.dart';
import 'package:kalender/features/calendar/presentation/provider/view_provider.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewProvider = context.watch<ViewProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Google Kalender'),
            automaticallyImplyLeading: false,
            elevation: 1,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8.0),
              children: [
                // Bagian untuk mengubah tampilan kalender
                _buildViewSwitcher(context, viewProvider, colorScheme),

                // Pemisah
                const Divider(indent: 16, endIndent: 16),

                // Menu untuk fitur-fitur lain
                ListTile(
                  leading: const Icon(Icons.check_box_outlined),
                  title: const Text('Tugas'),
                  onTap: () {
                    Navigator.pop(context); // Selalu tutup drawer dulu
                    Navigator.pushNamed(context, AppRouter.todoList);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh_outlined),
                  title: const Text('Segarkan'),
                  onTap: () {
                    context.read<EventProvider>().getEvents();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Pengaturan'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.settings);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk membangun pengalih tampilan
  Widget _buildViewSwitcher(BuildContext context, ViewProvider viewProvider,
      ColorScheme colorScheme) {
    return Column(
      children: [
        _buildViewTile(context, viewProvider, 'Jadwal', CalendarView.jadwal,
            Icons.view_agenda_outlined),
        _buildViewTile(context, viewProvider, 'Hari', CalendarView.hari,
            Icons.view_day_outlined),
        _buildViewTile(context, viewProvider, '3 Hari', CalendarView.tigaHari,
            Icons.view_column_outlined),
        _buildViewTile(context, viewProvider, 'Minggu', CalendarView.minggu,
            Icons.view_week_outlined),
        _buildViewTile(context, viewProvider, 'Bulan', CalendarView.bulan,
            Icons.calendar_view_month_outlined),
      ],
    );
  }

  // Helper untuk membuat satu baris item pilihan tampilan
  Widget _buildViewTile(
    BuildContext context,
    ViewProvider viewProvider,
    String title,
    CalendarView view,
    IconData icon,
  ) {
    final bool isSelected = viewProvider.currentView == view;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Material(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          onTap: () {
            viewProvider.changeView(view);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(24.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              children: [
                Icon(icon,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant),
                const SizedBox(width: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
