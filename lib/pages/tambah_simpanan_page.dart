import 'package:flutter/material.dart';
import '../data/simpanan_repository.dart';
import '../data/dummy_users.dart';

class TambahSimpananPage extends StatelessWidget {
  const TambahSimpananPage({super.key});

  @override
  Widget build(BuildContext context) {
    final jumlahController = TextEditingController();
    String? selectedUser;

    final anggota = DummyUsers.users
        .where((user) => user.role == 'anggota')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Simpanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Pilih Anggota',
                border: OutlineInputBorder(),
              ),
              items: anggota
                  .map(
                    (user) => DropdownMenuItem(
                      value: user.username,
                      child: Text('${user.nama} (${user.username})'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => selectedUser = value,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Simpanan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Simpan'),
                onPressed: () async {
                  if (selectedUser == null ||
                      jumlahController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pilih anggota dan isi jumlah')),
                    );
                    return;
                  }

                  final user = DummyUsers.getUserByUsername(selectedUser!);
                  if (user?.id != null) {
                    final success = await SimpananRepository.tambahSimpanan(
                      userId: user!.id!,
                      jumlah: double.parse(jumlahController.text),
                    );
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Simpanan berhasil ditambahkan')),
                      );
                      Navigator.pop(context, true); // Return true untuk refresh
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal menambah simpanan')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User tidak ditemukan')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
