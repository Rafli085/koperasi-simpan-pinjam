import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import '../data/simpanan_repository.dart';
import '../data/pinjaman_repository.dart';
import '../utils/format.dart';

class DashboardStatistikPage extends StatelessWidget {
  const DashboardStatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    // =========================
    // TOTAL ANGGOTA
    // =========================
    final totalAnggota = DummyUsers.users.entries
        .where((e) => e.value['role'] == 'anggota')
        .length;

    // =========================
    // TOTAL SIMPANAN
    // =========================
    final totalSimpanan = SimpananRepository.data.values
        .expand((list) => list)
        .fold<int>(0, (s, item) => s + (item['jumlah'] as int));

    // =========================
    // TOTAL PINJAMAN
    // =========================
    int totalPinjamanAktif = 0;
    int pinjamanMenunggu = 0;

    // ✅ AKSES DATA PINJAMAN AKTIF DENGAN BENAR
    final aktifData =
        PinjamanRepository.data['aktif'] as Map<String, List<Map<String, dynamic>>>;

    aktifData.forEach((_, pinjamanList) {
      for (var p in pinjamanList) {
        if (p['status'] == 'aktif') {
          totalPinjamanAktif += p['jumlah'] as int;
        }
        if (p['status'] == 'menunggu') {
          pinjamanMenunggu++;
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Statistik'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _StatCard(
            icon: Icons.people,
            title: 'Anggota',
            value: '$totalAnggota',
            color: Colors.blue,
          ),
          _StatCard(
            icon: Icons.savings,
            title: 'Total Simpanan',
            value: Format.rupiah(totalSimpanan),
            color: Colors.green,
          ),
          _StatCard(
            icon: Icons.credit_card,
            title: 'Pinjaman Aktif',
            value: Format.rupiah(totalPinjamanAktif),
            color: Colors.orange,
          ),
          _StatCard(
            icon: Icons.pending_actions,
            title: 'Menunggu Approval',
            value: '$pinjamanMenunggu',
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

// =========================
// WIDGET CARD STATISTIK
// =========================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
