import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import 'tambah_anggota_page.dart';

class KelolaAnggotaPage extends StatefulWidget {
  const KelolaAnggotaPage({super.key});

  @override
  State<KelolaAnggotaPage> createState() => _KelolaAnggotaPageState();
}

class _KelolaAnggotaPageState extends State<KelolaAnggotaPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();
    final anggota = DummyUsers.users
        .where(
          (user) =>
              user.role == 'anggota' &&
              (user.nama.toLowerCase().contains(query) ||
                  user.username.toLowerCase().contains(query)),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Anggota')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahAnggotaPage()),
          );
          if (result == true) {
            setState(() {}); // Refresh UI
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Cari Anggota',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: anggota.length,
              itemBuilder: (context, index) {
                final user = anggota[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                              'Reset password untuk ${user.username} (fitur belum tersedia)',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
