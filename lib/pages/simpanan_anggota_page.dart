import 'package:flutter/material.dart';
import '../data/simpanan_repository.dart';
import '../utils/format.dart';

class SimpananAnggotaPage extends StatelessWidget {
  final String username;

  const SimpananAnggotaPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final riwayat = SimpananRepository.data[username] ?? [];
    final total = SimpananRepository.totalSimpanan(username);

    return Scaffold(
      appBar: AppBar(title: const Text('Simpanan Saya')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.savings),
                title: const Text('Total Simpanan'),
                subtitle: Text(
                  Format.rupiah(total),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Simpanan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: riwayat.isEmpty
                ? const Center(child: Text('Belum ada simpanan'))
                : ListView.builder(
                    itemCount: riwayat.length,
                    itemBuilder: (context, index) {
                      final item = riwayat[index];
                      return ListTile(
                        leading: const Icon(Icons.payments),
                        title: Text(Format.rupiah(item['jumlah'] as int)),
                        subtitle:
                            Text(Format.tanggal(item['tanggal'] as String)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
