import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';
import '../data/dummy_users.dart';

class TambahPinjamanPage extends StatelessWidget {
  const TambahPinjamanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final jumlahController = TextEditingController();
    final tenorController = TextEditingController();
    String? selectedUser;

    final anggota = DummyUsers.users
        .where((user) => user.role == 'anggota')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pinjaman')),
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
                labelText: 'Jumlah Pinjaman',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tenorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tenor (bulan)',
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
                      jumlahController.text.isEmpty ||
                      tenorController.text.isEmpty) {
                    return;
                  }

                  final user = DummyUsers.getUserByUsername(selectedUser!);
                  if (user?.id != null) {
                    await PinjamanRepository.tambahPinjaman(
                      userId: user!.id!,
                      jumlah: double.parse(jumlahController.text),
                      tenor: int.parse(tenorController.text),
                    );
                  }

                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
