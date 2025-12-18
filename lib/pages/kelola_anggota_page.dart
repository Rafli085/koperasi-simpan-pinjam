import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import 'tambah_anggota_page.dart';

class KelolaAnggotaPage extends StatelessWidget {
  const KelolaAnggotaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final anggota = DummyUsers.users.entries
        .where((e) => e.value['role'] == 'anggota')
        .toList();

    void hapusAnggota(BuildContext context, String username) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Apakah Anda yakin ingin menghapus anggota dengan username "$username"?',
          ),
          action: SnackBarAction(
            label: 'HAPUS',
            onPressed: () async {
              DummyUsers.hapusAnggota(username);
              await DummyUsers.save();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Anggota "$username" berhasil dihapus'),
                ),
              );

              (context as Element).markNeedsBuild();
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Anggota')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahAnggotaPage(),
            ),
          );
          (context as Element).markNeedsBuild();
        },
      ),
      body: ListView.builder(
        itemCount: anggota.length,
        itemBuilder: (context, index) {
          final entry = anggota[index];
          final username = entry.key;
          final user = entry.value;

          return Card(
            margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user['nama'] ?? username),
              subtitle: Text('Username: $username'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    child: const Text('Reset Password'),
                    onPressed: () async {
                      user['password'] = '123456';
                      await DummyUsers.save();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Password $username direset ke 123456'),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => hapusAnggota(context, username),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
