import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import 'tambah_anggota_page.dart';

class KelolaAnggotaPage extends StatefulWidget {
  const KelolaAnggotaPage({super.key});

  @override
  State<KelolaAnggotaPage> createState() => _KelolaAnggotaPageState();
}

class _KelolaAnggotaPageState extends State<KelolaAnggotaPage> {
  @override
  Widget build(BuildContext context) {
    final anggota = DummyUsers.users
        .where((user) => user.role == 'anggota')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Anggota')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahAnggotaPage(),
            ),
          );
          if (result == true) {
            setState(() {}); // Refresh UI
          }
        },
      ),
      body: ListView.builder(
        itemCount: anggota.length,
        itemBuilder: (context, index) {
          final user = anggota[index];

          return Card(
            margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.nama),
              subtitle: Text('Username: ${user.username}'),
              trailing: TextButton(
                child: const Text('Reset Password'),
                onPressed: () async {
                  // TODO: Implement reset password API
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Reset password untuk ${user.username} (fitur belum tersedia)'),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
