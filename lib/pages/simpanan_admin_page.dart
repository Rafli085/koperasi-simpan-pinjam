import 'package:flutter/material.dart';
import '../data/simpanan_repository.dart';
import '../utils/format.dart';
import 'tambah_simpanan_page.dart';

class SimpananAdminPage extends StatelessWidget {
  const SimpananAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = SimpananRepository.data.entries.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Data Simpanan Anggota')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahSimpananPage(),
            ),
          );
        },
      ),
      body: entries.isEmpty
          ? const Center(child: Text('Belum ada simpanan'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                final total = SimpananRepository.totalSimpanan(e.key);

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(e.key),
                  subtitle: Text(
                    'Total: ${Format.rupiah(total)}',
                  ),
                );
              },
            ),
    );
  }
}
