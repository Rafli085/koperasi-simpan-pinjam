import 'package:flutter/material.dart';
import '../services/pinjaman_service.dart';
import '../models/pinjaman_model.dart';
import '../utils/format.dart';

class ApprovalPinjamanPage extends StatelessWidget {
  const ApprovalPinjamanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Pinjaman')),
      body: FutureBuilder<List<Pinjaman>>(
        future: PinjamanService.getAllPinjaman(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final pinjamanList = (snapshot.data ?? [])
              .where((p) => p.status == 'menunggu')
              .toList();
          
          return pinjamanList.isEmpty
              ? const Center(child: Text('Tidak ada pinjaman yang menunggu approval'))
              : ListView.builder(
                  itemCount: pinjamanList.length,
                  itemBuilder: (context, index) {
                    final p = pinjamanList[index];
                    
                    return Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: Text('User ID: ${p.userId}'),
                        subtitle: Text('Jumlah: ${Format.rupiah(p.jumlah)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                await PinjamanService.updateStatus(
                                  pinjamanId: p.id!,
                                  status: 'aktif',
                                );
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await PinjamanService.updateStatus(
                                  pinjamanId: p.id!,
                                  status: 'ditolak',
                                );
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
