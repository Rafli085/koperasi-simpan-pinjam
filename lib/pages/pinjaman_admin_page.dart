import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';
import '../utils/format.dart';
import 'tambah_pinjaman_page.dart';
import 'cicilan_pinjaman_page.dart';

class PinjamanAdminPage extends StatelessWidget {
  const PinjamanAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, dynamic>>> dataAktif =
        Map<String, List<Map<String, dynamic>>>.from(
      PinjamanRepository.data['aktif'] ?? {},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pinjaman Anggota'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahPinjamanPage(),
            ),
          );
          Navigator.pop(context);
        },
      ),
      body: dataAktif.isEmpty
          ? const Center(child: Text('Belum ada data pinjaman'))
          : ListView(
              children: dataAktif.entries.map((entry) {
                final username = entry.key;
                final pinjamanList = entry.value;

                if (pinjamanList.isEmpty) {
                  return const SizedBox();
                }

                return ExpansionTile(
                  title: Text(username),
                  children: pinjamanList.map((p) {
                    final int sisa =
                        PinjamanRepository.sisaPinjaman(p);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading:
                            const Icon(Icons.credit_card),
                        title: Text(
                          Format.rupiah(p['jumlah'] as int),
                        ),
                        subtitle: Text(
                          'Status: ${p['status']} • '
                          'Sisa: ${Format.rupiah(sisa)}',
                        ),
                        trailing: Chip(
                          label: Text(p['status']),
                          backgroundColor:
                              _statusColor(p['status']),
                        ),
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
                  }).toList(),
                );
              }).toList(),
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
