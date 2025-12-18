import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';
import '../utils/format.dart';
import 'cicilan_pinjaman_page.dart';

class PinjamanAnggotaPage extends StatelessWidget {
  final String username;

  const PinjamanAnggotaPage({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    final aktif =
        PinjamanRepository.data['aktif'] ?? {};

    final List<Map<String, dynamic>> list =
        List<Map<String, dynamic>>.from(
          aktif[username] ?? [],
        ).where((p) => p['status'] != 'ditolak').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinjaman Saya'),
      ),
      body: list.isEmpty
          ? const Center(child: Text('Belum ada pinjaman'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final p = list[index];
                final int sisa =
                    PinjamanRepository.sisaPinjaman(p);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.credit_card),
                    title: Text(
                      Format.rupiah(p['jumlah'] as int),
                    ),
                    subtitle: Text(
                      'Tenor: ${p['tenor']} bulan • '
                      'Sisa: ${Format.rupiah(sisa)}',
                    ),
                    trailing: Chip(
                      label: Text(p['status']),
                      backgroundColor:
                          _statusColor(p['status']),
                    ),
                    enabled: p['status'] == 'aktif',
                    onTap: p['status'] == 'aktif'
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CicilanPinjamanPage(
                                  username: username,
                                  pinjamanId: p['id'],
                                ),
                              ),
                            );
                          }
                        : null,
                  ),
                );
              },
            ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'aktif':
        return Colors.green[100]!;
      case 'menunggu':
        return Colors.orange[100]!;
      case 'lunas':
        return Colors.blue[100]!;
      default:
        return Colors.grey[200]!;
    }
  }
}
