import 'package:flutter/material.dart';
import 'simpanan_admin_page.dart';
import 'pinjaman_admin_page.dart';
import 'kelola_anggota_page.dart';
import 'approval_pinjaman_page.dart';
import 'dashboard_statistik_page.dart';
import 'event_admin_page.dart';

class DashboardAdmin extends StatelessWidget {
  final VoidCallback onLogout;
  final String role;

  const DashboardAdmin({
    super.key,
    required this.onLogout,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin ($role)'),
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
          // ===== STATISTIK =====
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blue),
              title: const Text('Dashboard Statistik'),
              subtitle: const Text('Ringkasan kondisi koperasi'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardStatistikPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ===== SIMPANAN =====
          Card(
            child: ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Data Simpanan'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SimpananAdminPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ===== PINJAMAN =====
          Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Data Pinjaman'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PinjamanAdminPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          if (role == 'ketua') ...[
            Card(
              color: Colors.orange[50],
              child: ListTile(
                leading:
                    const Icon(Icons.verified, color: Colors.orange),
                title: const Text('Approval Pinjaman'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApprovalPinjamanPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ===== ANGGOTA =====
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Kelola Anggota'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KelolaAnggotaPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ===== EVENT =====
          Card(
            color: Colors.purple[50],
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.purple),
              title: const Text('Kelola Event'),
              subtitle: const Text('Pengumuman dan polling untuk anggota'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EventAdminPage(),
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
