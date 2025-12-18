import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';
import '../utils/format.dart';
import 'tambah_cicilan_page.dart';

class CicilanPinjamanPage extends StatelessWidget {
  final String username;
  final String pinjamanId;

  const CicilanPinjamanPage({
    super.key,
    required this.username,
    required this.pinjamanId,
  });

  Map<String, dynamic>? _getPinjaman() {
    final list = PinjamanRepository.data['aktif']![username];
    if (list == null) return null;

    return list.firstWhere(
      (p) => p['id'] == pinjamanId,
      orElse: () => {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinjaman = _getPinjaman();

    if (pinjaman == null || pinjaman.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Data pinjaman tidak ditemukan')),
      );
    }

    final List<Map<String, dynamic>> cicilan =
        List<Map<String, dynamic>>.from(pinjaman['cicilan'] ?? []);

    cicilan.sort((a, b) =>
        DateTime.parse(a['tanggal']).compareTo(
          DateTime.parse(b['tanggal']),
        ));

    final int tenor = pinjaman['tenor'];
    final int jumlahCicilan = cicilan.length;
    final int sisa = PinjamanRepository.sisaPinjaman(pinjaman);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pinjaman')),
      floatingActionButton: pinjaman['status'] == 'aktif'
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TambahCicilanPage(
                      username: username,
                      pinjamanId: pinjamanId,
                    ),
                  ),
                );
                // 🔥 REBUILD halaman ini
                (context as Element).markNeedsBuild();
              },
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(
                Format.rupiah(pinjaman['jumlah']),
              ),
              subtitle: Text(
                'Tenor: $tenor bulan • '
                'Cicilan: $jumlahCicilan',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Riwayat Cicilan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          cicilan.isEmpty
              ? const Text('Belum ada cicilan')
              : Column(
                  children: cicilan.map((c) {
                    return ListTile(
                      leading: const Icon(Icons.payments),
                      title: Text(
                        Format.rupiah(c['jumlah']),
                      ),
                      subtitle: Text(
                        Format.tanggal(c['tanggal']),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
