import 'package:flutter/material.dart';

class ModeSelectionPage extends StatelessWidget {
  final Function(String) onSelectMode;

  const ModeSelectionPage({super.key, required this.onSelectMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Mode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Pilih mode penggunaan aplikasi',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                title: const Text('Mode Sederhana'),
                subtitle: const Text('Ringkas & mudah digunakan'),
                onTap: () => onSelectMode('sederhana'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: const Text('Mode Lengkap'),
                subtitle: const Text('Fitur anggota lengkap'),
                onTap: () => onSelectMode('lengkap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
