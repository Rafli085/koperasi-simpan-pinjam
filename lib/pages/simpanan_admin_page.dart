import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import '../services/simpanan_service.dart';
import '../utils/format.dart';
import 'tambah_simpanan_page.dart';

class SimpananAdminPage extends StatefulWidget {
  const SimpananAdminPage({super.key});

  @override
  State<SimpananAdminPage> createState() => _SimpananAdminPageState();
}

class _SimpananAdminPageState extends State<SimpananAdminPage> {
  @override
  Widget build(BuildContext context) {
    final anggota = DummyUsers.users.where((user) => user.role == 'anggota').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Data Simpanan Anggota')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahSimpananPage(),
            ),
          );
          if (result == true) {
            setState(() {}); // Refresh UI
          }
        },
      ),
      body: ListView.builder(
        itemCount: anggota.length,
        itemBuilder: (context, index) {
          final user = anggota[index];
          
          return FutureBuilder<double>(
            future: SimpananService.getTotalSimpanan(user.id!),
            builder: (context, snapshot) {
              final total = snapshot.data ?? 0.0;
              
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(user.nama),
                subtitle: Text('Total: ${Format.rupiah(total)}'),
              );
            },
          );
        },
      ),
    );
  }
}
