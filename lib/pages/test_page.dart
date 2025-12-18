import 'package:flutter/material.dart';
import '../data/dummy_users.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Database')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final user = await DummyUsers.login('anggota1', '123456');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(user != null 
                      ? 'Login berhasil: ${user.nama}' 
                      : 'Login gagal'),
                  ),
                );
              },
              child: const Text('Test Login anggota1'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await DummyUsers.load();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Users loaded: ${DummyUsers.users.length}'),
                  ),
                );
              },
              child: const Text('Load Users'),
            ),
          ],
        ),
      ),
    );
  }
}