import 'package:flutter/material.dart';
import '../data/simpanan_repository.dart';
import '../data/dummy_users.dart';

class TambahSimpananPage extends StatelessWidget {
  const TambahSimpananPage({super.key});

  @override
  Widget build(BuildContext context) {
    final jumlahController = TextEditingController();
    String? selectedUser;

    final anggota = DummyUsers.users.entries
        .where((e) => e.value['role'] == 'anggota')
        .map((e) => e.key)
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
                    (u) => DropdownMenuItem(
                      value: u,
                      child: Text(u),
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
                    return;
                  }

                  await SimpananRepository.tambahSimpanan(
                    selectedUser!,
                    int.parse(jumlahController.text),
                  );

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
