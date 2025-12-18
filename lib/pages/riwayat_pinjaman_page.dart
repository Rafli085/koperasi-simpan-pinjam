import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';
import '../utils/format.dart';

class RiwayatPinjamanPage extends StatelessWidget {
  const RiwayatPinjamanPage({super.key});

  Map<String, List<Map<String, dynamic>>> _groupByBulan(
      List<Map<String, dynamic>> data) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var p in data) {
      final date = DateTime.parse(p['tanggalLunas']);
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(p);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final riwayat = PinjamanRepository.semuaRiwayat();
    final grouped = _groupByBulan(riwayat);
    final bulanKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pinjaman')),
      body: bulanKeys.isEmpty
          ? const Center(child: Text('Belum ada riwayat pinjaman'))
          : ListView.builder(
              itemCount: bulanKeys.length,
              itemBuilder: (context, index) {
                final bulan = bulanKeys[index];
                final data = grouped[bulan]!;

                data.sort((a, b) => DateTime.parse(a['tanggalLunas'])
                    .compareTo(DateTime.parse(b['tanggalLunas'])));

                return ExpansionTile(
                  title: Text(
                    Format.bulanTahun(bulan),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: data.map((p) {
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(
                          '${p['username']} • ${Format.rupiah(p['jumlah'])}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tenor: ${p['tenor']} bulan'),
                            Text('Mulai: ${Format.tanggal(p['tanggalMulai'])}'),
                            Text('Lunas: ${Format.tanggal(p['tanggalLunas'])}'),
                          ],
                        ),
                        trailing: const Chip(
                          label: Text('LUNAS'),
                          backgroundColor: Colors.greenAccent,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
