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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editSimpanan(user),
                      tooltip: 'Edit Simpanan',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _hapusSimpanan(user),
                      tooltip: 'Hapus Simpanan',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _editSimpanan(user) {
    // Navigate to edit page or show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Simpanan ${user.nama}'),
        content: const Text('Fitur edit simpanan akan segera tersedia'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _hapusSimpanan(user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Simpanan'),
        content: Text('Apakah Anda yakin ingin menghapus semua simpanan ${user.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              await SimpananService.hapusSemuaSimpanan(user.id!);
              
              setState(() {});
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Simpanan ${user.nama} berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
