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
              trailing: TextButton(
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
            ),
          );
        },
      ),
    );
  }
}
