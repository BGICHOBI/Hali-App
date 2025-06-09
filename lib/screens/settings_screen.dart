// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../main.dart'; // for themeModeProvider and global `analytics`

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dark Mode Toggle
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6, color: Colors.teal),
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (val) {
              // Log theme toggle
              analytics.logEvent(
                name: 'settings_toggle_theme',
                parameters: {'mode': val ? 'dark' : 'light'},
              );
              // Apply theme
              ref.read(themeModeProvider.notifier).state =
                  val ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(),

          const Text(
            'Account Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildSettingsTile(
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              analytics.logEvent(name: 'settings_profile_tap');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile clicked')),
              );
            },
          ),
          const Divider(),

          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            onTap: () {
              analytics.logEvent(name: 'settings_notifications_tap');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications clicked')),
              );
            },
          ),
          const Divider(),

          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              analytics.logEvent(name: 'settings_privacy_tap');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy Policy clicked')),
              );
            },
          ),
          const Divider(),

          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Log Out',
            onTap: () {
              analytics.logEvent(name: 'settings_logout');
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
