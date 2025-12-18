import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';

class TambahCicilanPage extends StatelessWidget {
  final int pinjamanId;

  const TambahCicilanPage({
    super.key,
    required this.pinjamanId,
  });

  @override
  Widget build(BuildContext context) {
    final jumlahController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Cicilan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Cicilan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Simpan'),
                onPressed: () async {
                  if (jumlahController.text.isEmpty) return;

                  await PinjamanRepository.tambahCicilan(
                    pinjamanId: pinjamanId,
                    jumlah: double.parse(jumlahController.text),
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
