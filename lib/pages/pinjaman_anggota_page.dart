import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import '../services/pinjaman_service.dart';
import '../models/pinjaman_model.dart';
import '../utils/format.dart';

class PinjamanAnggotaPage extends StatelessWidget {
  final String username;

  const PinjamanAnggotaPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final user = DummyUsers.getUserByUsername(username);

    return Scaffold(
      appBar: AppBar(title: const Text('Pinjaman Saya')),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : FutureBuilder<List<Pinjaman>>(
              future: PinjamanService.getPinjamanByUser(user.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final pinjamanList = (snapshot.data ?? [])
                    .where((p) => p.status != 'ditolak')
                    .toList();

                return pinjamanList.isEmpty
                    ? const Center(child: Text('Belum ada pinjaman'))
                    : ListView.builder(
                        itemCount: pinjamanList.length,
                        itemBuilder: (context, index) {
                          final p = pinjamanList[index];
                          final sisa = p.sisaPinjaman;

                          return Card(
                            child: ListTile(
                              title: Text(Format.rupiah(p.jumlah)),
                              subtitle: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal Pinjam: '
                                    '${Format.tanggal(
                                      p.tanggal.toIso8601String(),
                                    )}',
                                  ),
                                  if (p.tanggalApproval != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tanggal Approval: '
                                      '${Format.tanggal(
                                        p.tanggalApproval!
                                            .toIso8601String(),
                                      )}',
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    'Status: ${p.status} • '
                                    'Sisa: ${Format.rupiah(sisa)}',
                                  ),
                                ],
                              ),
                              enabled: p.status == 'aktif',
                            ),
                          );
                        },
                      );
              },
            ),
    );
  }
}
