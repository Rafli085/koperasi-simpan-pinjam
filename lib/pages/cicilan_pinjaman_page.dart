import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';
import '../utils/format.dart';
import 'tambah_cicilan_page.dart';

class CicilanPinjamanPage extends StatelessWidget {
  final String username;
  final Map<String, dynamic> pinjaman;

  const CicilanPinjamanPage({
    super.key,
    required this.username,
    required this.pinjaman,
  });

  @override
  Widget build(BuildContext context) {
    final cicilan = pinjaman['cicilan'] as List;
    final sisa = PinjamanRepository.sisaPinjaman(pinjaman);

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
                      username : username,
                      pinjamanId: pinjaman['id'],
                    ),
                  ),
                );
                Navigator.pop(context);
              },
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text(Format.rupiah(pinjaman['jumlah'] as int)),
              subtitle: Text('Sisa: ${Format.rupiah(sisa)}'),
              trailing: Chip(label: Text(pinjaman['status'])),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Riwayat Cicilan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...cicilan.map(
            (c) => ListTile(
              leading: const Icon(Icons.payments),
              title: Text(Format.rupiah(c['jumlah'] as int)),
              subtitle: Text(
                Format.tanggal(
                  DateTime.parse(c['tanggal']).toIso8601String(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
