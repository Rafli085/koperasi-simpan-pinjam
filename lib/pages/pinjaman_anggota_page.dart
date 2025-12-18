import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';
import '../utils/format.dart';
import 'cicilan_pinjaman_page.dart';

class PinjamanAnggotaPage extends StatelessWidget {
  final String username;

  const PinjamanAnggotaPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final pinjamanList = (PinjamanRepository.data[username] ?? [])
        .where((p) => p['status'] != 'ditolak')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pinjaman Saya')),
      body: pinjamanList.isEmpty
          ? const Center(child: Text('Belum ada pinjaman'))
          : ListView.builder(
              itemCount: pinjamanList.length,
              itemBuilder: (context, index) {
                final p = pinjamanList[index];
                final sisa = PinjamanRepository.sisaPinjaman(p);

                return Card(
                  child: ListTile(
                    title: Text(Format.rupiah(p['jumlah'])),
                    subtitle: Text(
                      'Status: ${p['status']} • '
                      'Sisa: ${Format.rupiah(sisa)}',
                    ),
                    enabled: p['status'] == 'aktif',
                    onTap: p['status'] == 'aktif'
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CicilanPinjamanPage(
                                  username: username,
                                  pinjaman: p,
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
}
