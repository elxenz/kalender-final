// lib/features/calendar/presentation/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:kalender/app/config/router/app_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Kalender',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Kalender'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.calendar,
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRouter.settings);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Tentang'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Kalender',
                applicationVersion: '1.0.0',
                children: [
                  const Text(
                      'Aplikasi kalender sederhana untuk mengelola acara dan pengingat.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
