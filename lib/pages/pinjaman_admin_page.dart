import 'package:flutter/material.dart';
import '../services/pinjaman_service.dart';
import '../models/pinjaman_model.dart';
import '../utils/format.dart';
import 'tambah_pinjaman_page.dart';
import '../services/user_service.dart';

class PinjamanAdminPage extends StatelessWidget {
  const PinjamanAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<Pinjaman>>(
        future: PinjamanService.getAllPinjaman(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pinjamanList = snapshot.data ?? [];

          return pinjamanList.isEmpty
              ? const Center(child: Text('Belum ada data pinjaman'))
              : ListView.builder(
                  itemCount: pinjamanList.length,
                  itemBuilder: (context, index) {
                    final p = pinjamanList[index];
                    final sisa = p.sisaPinjaman;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.credit_card),
                        title: Text(Format.rupiah(p.jumlah)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String>(
                              future: UserService.getUsernameById(p.userId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text('Nama: memuat...');
                                }
                                return Text(
                                  'Nama: ${snapshot.data ?? '-'}',
                                );
                              },
                            ),
                            const SizedBox(height: 4),
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
                                  p.tanggalApproval!.toIso8601String(),
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
                        trailing: Chip(
                          label: Text(p.status),
                          backgroundColor: _statusColor(p.status),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  Color? _statusColor(String status) {
    switch (status) {
      case 'aktif':
        return Colors.green[100];
      case 'menunggu':
        return Colors.orange[100];
      case 'ditolak':
        return Colors.red[100];
      case 'lunas':
        return Colors.blue[100];
      default:
        return null;
    }
  }
}
