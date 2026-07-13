// lib/screens/settings_screen.dart
// STEP 10 — Settings Screen (Dark/Light Mode Toggle)
// Paste this file in: lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/theme_service.dart';
import '../../../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          SwitchListTile(
            secondary: Icon(
              themeService.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Dark Mode'),
            subtitle: Text(themeService.isDarkMode
                ? 'Dark theme is ON'
                : 'Light theme is ON'),
            value: themeService.isDarkMode,
            onChanged: (_) => themeService.toggleTheme(),
          ),
          const Divider(),
          const _SectionHeader('Notifications'),
          ListTile(
            leading: Icon(Icons.notifications_active,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a sample reminder now'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              NotificationService().showInstantNotification(
                title: '🩸 Sugar Check Reminder',
                body: 'This is a test reminder from Diabetes App!',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test notification sent!')),
              );
            },
          ),
          const Divider(),
          const _SectionHeader('About'),
          ListTile(
            leading: Icon(Icons.info_outline,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: Icon(Icons.medical_services,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Disclaimer'),
            subtitle: const Text('Tap to read'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Medical Disclaimer'),
                  content: const Text(
                    'This app is for informational purposes only and is NOT '
                    'a substitute for professional medical advice, diagnosis, '
                    'or treatment. Always seek the advice of a qualified '
                    'healthcare provider with any questions you may have '
                    'regarding your medical condition.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('I Understand'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
