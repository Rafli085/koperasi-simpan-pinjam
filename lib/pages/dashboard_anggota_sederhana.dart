import 'package:flutter/material.dart';
import 'simpanan_anggota_page.dart';
import 'pinjaman_anggota_page.dart';

class DashboardAnggotaSederhana extends StatelessWidget {
  final String username;
  final VoidCallback onLogout;

  const DashboardAnggotaSederhana({
    super.key,
    required this.username,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Anggota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.savings),
                title: const Text('Simpanan Saya'),
                subtitle: const Text('Saldo & riwayat simpanan'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SimpananAnggotaPage(username: username),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Pinjaman Saya'),
                subtitle: const Text('Status & total pinjaman'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PinjamanAnggotaPage(username: username),
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
