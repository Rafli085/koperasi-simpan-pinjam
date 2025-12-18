import 'package:flutter/material.dart';
import '../data/pinjaman_repository.dart';
import '../data/dummy_users.dart';

class TambahPinjamanPage extends StatefulWidget {
  const TambahPinjamanPage({super.key});

  @override
  State<TambahPinjamanPage> createState() => _TambahPinjamanPageState();
}

class _TambahPinjamanPageState extends State<TambahPinjamanPage> {
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController tenorController = TextEditingController();

  String? selectedUser;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final anggota = DummyUsers.users.entries
        .where((e) => e.value['role'] == 'anggota')
        .map((e) => e.key)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pinjaman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // =========================
            // PILIH ANGGOTA
            // =========================
            DropdownButtonFormField<String>(
              value: selectedUser,
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
              onChanged: (value) {
                setState(() {
                  selectedUser = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // =========================
            // JUMLAH PINJAMAN
            // =========================
            TextField(
              controller: jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Pinjaman',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // TENOR
            // =========================
            TextField(
              controller: tenorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tenor (bulan)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // BUTTON SIMPAN
            // =========================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _simpanPinjaman,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // LOGIKA SIMPAN PINJAMAN
  // =========================
  Future<void> _simpanPinjaman() async {
    if (selectedUser == null ||
        jumlahController.text.isEmpty ||
        tenorController.text.isEmpty) {
      _showSnack('Semua field wajib diisi');
      return;
    }

    final jumlah = int.tryParse(jumlahController.text);
    final tenor = int.tryParse(tenorController.text);

    if (jumlah == null || jumlah <= 0) {
      _showSnack('Jumlah pinjaman tidak valid');
      return;
    }

    if (tenor == null || tenor <= 0) {
      _showSnack('Tenor tidak valid');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await PinjamanRepository.tambahPinjaman(
        username: selectedUser!,
        jumlah: jumlah,
        tenor: tenor,
      );

      if (!mounted) return;

      _showSnack('Pinjaman berhasil ditambahkan');
      Navigator.pop(context);

    } catch (e) {
      _showSnack('Gagal menyimpan pinjaman');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
