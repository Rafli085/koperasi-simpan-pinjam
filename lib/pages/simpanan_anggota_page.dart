import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import '../services/simpanan_service.dart';
import '../models/simpanan_model.dart';
import '../utils/format.dart';

class SimpananAnggotaPage extends StatelessWidget {
  final String username;

  const SimpananAnggotaPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final user = DummyUsers.getUserByUsername(username);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Simpanan Saya')),
      body: user == null 
        ? const Center(child: Text('User tidak ditemukan'))
        : FutureBuilder<List<Simpanan>>(
            future: SimpananService.getSimpananByUser(user.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final riwayat = snapshot.data ?? [];
              final total = riwayat.fold<double>(0.0, (sum, item) => sum + item.jumlah);
              
              return Column(
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
                                title: Text(Format.rupiah(item.jumlah)),
                                subtitle: Text(Format.tanggal(item.tanggal.toIso8601String())),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
    );
  }
}
