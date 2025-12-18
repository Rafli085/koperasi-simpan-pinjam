import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';

class ApprovalPinjamanPage extends StatelessWidget {
  const ApprovalPinjamanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = PinjamanRepository.data.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Approval Pinjaman')),
      body: ListView(
        children: entries.expand((entry) {
          final username = entry.key;
          return entry.value
              .where((p) => p['status'] == 'menunggu')
              .map(
                (p) => Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text('Anggota: $username'),
                    subtitle: Text('Jumlah: Rp ${p['jumlah']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            await PinjamanRepository.setStatus(
                              username: username,
                              pinjamanId: p['id'],
                              status: 'aktif',
                            );
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            await PinjamanRepository.setStatus(
                              username: username,
                              pinjamanId: p['id'],
                              status: 'ditolak',
                            );
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
