import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';

class ApprovalPinjamanPage extends StatelessWidget {
  const ApprovalPinjamanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> aktif =
        PinjamanRepository.data['aktif'] ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Approval Pinjaman')),
      body: aktif.isEmpty
          ? const Center(child: Text('Tidak ada pengajuan'))
          : ListView(
              children: aktif.entries.expand((entry) {
                final String username = entry.key;
                final List list = entry.value ?? [];

                return list
                    .where((p) => p['status'] == 'menunggu')
                    .map(
                      (p) => Card(
                        margin: const EdgeInsets.all(12),
                        child: ListTile(
                          title: Text('Anggota: $username'),
                          subtitle: Text(
                            'Jumlah: ${p['jumlah']} • '
                            'Tenor: ${p['tenor']} bulan',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () async {
                                  await PinjamanRepository
                                      .approvePinjaman(
                                    username: username,
                                    pinjamanId: p['id'],
                                  );
                                  Navigator.pop(context);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.red),
                                onPressed: () async {
                                  p['status'] = 'ditolak';
                                  await PinjamanRepository.save();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
              }).toList(),
            ),
    );
  }
}
