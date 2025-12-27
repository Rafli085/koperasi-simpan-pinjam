import 'package:flutter/material.dart';
import 'simpanan_anggota_page.dart';
import 'pinjaman_anggota_page.dart';
import 'event_anggota_page.dart';

class DashboardAnggotaLengkap extends StatelessWidget {
  final String username;
  final int userId;
  final VoidCallback onLogout;

  const DashboardAnggotaLengkap({
    super.key,
    required this.username,
    required this.userId,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Anggota Lengkap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
              subtitle: const Text('Status & cicilan pinjaman'),
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
          const SizedBox(height: 12),
          Card(
            color: Colors.purple[50],
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.purple),
              title: const Text('Event & Pengumuman'),
              subtitle: const Text('Lihat pengumuman dan ikuti polling'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventAnggotaPage(userId: userId),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Informasi Koperasi'),
              subtitle: const Text('Kontak dan informasi umum'),
            ),
          ),
        ],
      ),
    );
  }
}
