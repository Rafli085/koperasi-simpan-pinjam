import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final Function(ThemeMode) onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SwitchListTile(
        title: const Text('Mode Gelap'),
        subtitle: const Text('Aktifkan tampilan gelap'),
        value: isDark,
        onChanged: (value) {
          onThemeChanged(
            value ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}
