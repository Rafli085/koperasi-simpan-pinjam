import 'package:flutter/material.dart';
import '../data/dummy_users.dart';

class TambahAnggotaPage extends StatelessWidget {
  const TambahAnggotaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final namaController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    void simpan() async {
      if (namaController.text.isEmpty ||
          usernameController.text.isEmpty ||
          passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field wajib diisi')),
        );
        return;
      }

      final success = await DummyUsers.tambahAnggota(
        nama: namaController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anggota berhasil ditambahkan')),
        );
        Navigator.pop(context, true); // Return true untuk refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambah anggota')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Anggota')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Anggota',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username / No Anggota',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password Awal',
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
