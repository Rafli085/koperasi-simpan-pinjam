import 'package:flutter/material.dart';
import '../data/dummy_users.dart';

class GantiPasswordPage extends StatelessWidget {
  final String username;

  const GantiPasswordPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final lamaController = TextEditingController();
    final baruController = TextEditingController();
    final konfirmasiController = TextEditingController();

    void simpan() async {
      final user = DummyUsers.users[username]!;

      if (lamaController.text != user['password']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password lama salah')),
        );
        return;
      }

      if (baruController.text != konfirmasiController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konfirmasi password tidak cocok')),
        );
        return;
      }

      if (baruController.text == lamaController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password baru tidak boleh sama')),
        );
        return;
      }

      user['password'] = baruController.text;
      await DummyUsers.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah')),
      );

      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ganti Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: lamaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: baruController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: konfirmasiController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: simpan,
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
