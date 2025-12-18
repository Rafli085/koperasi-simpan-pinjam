import 'package:flutter/material.dart';

import 'simpanan_admin_page.dart';
import 'pinjaman_admin_page.dart';
import 'kelola_anggota_page.dart';
import 'approval_pinjaman_page.dart';
import 'dashboard_statistik_page.dart';
import 'riwayat_pinjaman_page.dart';

class DashboardAdmin extends StatelessWidget {
  final VoidCallback onLogout;
  final String role; // admin_keuangan | ketua

  const DashboardAdmin({
    super.key,
    required this.onLogout,
    required this.role,
  });

  bool get isKetua => role == 'ketua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKetua ? 'Dashboard Ketua' : 'Dashboard Admin',
        ),
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
          // ======================
          // DASHBOARD STATISTIK
          // ======================
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

          // ======================
          // DATA SIMPANAN
          // ======================
          Card(
            child: ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Data Simpanan'),
              subtitle: const Text('Kelola simpanan anggota'),
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

          // ======================
          // DATA PINJAMAN
          // ======================
          Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Data Pinjaman'),
              subtitle: const Text('Pinjaman aktif & pengajuan'),
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

          // ======================
          // RIWAYAT PINJAMAN (BARU)
          // ======================
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Riwayat Pinjaman'),
              subtitle: const Text('Pinjaman yang telah lunas'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RiwayatPinjamanPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ======================
          // APPROVAL (KETUA SAJA)
          // ======================
          if (isKetua) ...[
            Card(
              color: Colors.orange[50],
              child: ListTile(
                leading: const Icon(Icons.verified, color: Colors.orange),
                title: const Text('Approval Pinjaman'),
                subtitle: const Text('Setujui atau tolak pengajuan'),
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

          // ======================
          // KELOLA ANGGOTA
          // ======================
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Kelola Anggota'),
              subtitle: const Text('Tambah & kelola anggota'),
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
        ],
      ),
    );
  }
}
