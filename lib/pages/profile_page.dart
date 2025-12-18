import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import 'ganti_password_page.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final String role;

  const ProfilePage({
    super.key,
    required this.username,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final user = DummyUsers.users[username]!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.account_circle, size: 100),
            const SizedBox(height: 12),
            Text(
              user['nama'] ?? username,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Role: $role'),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Ganti Password'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GantiPasswordPage(username: username),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
