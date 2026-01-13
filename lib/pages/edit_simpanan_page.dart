import 'package:flutter/material.dart';
import '../services/simpanan_service.dart';
import '../utils/format.dart';

class EditSimpananPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditSimpananPage({super.key, required this.user});

  @override
  State<EditSimpananPage> createState() => _EditSimpananPageState();
}

class _EditSimpananPageState extends State<EditSimpananPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Simpanan ${widget.user['nama']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anggota: ${widget.user['nama']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('No. Anggota: ${widget.user['nomorAnggota'] ?? '-'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Simpanan',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah harus diisi';
                  }
                  final jumlah = double.tryParse(value);
                  if (jumlah == null || jumlah <= 0) {
                    return 'Jumlah harus berupa angka positif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _simpanSimpanan,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Tambah Simpanan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _simpanSimpanan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final jumlah = double.parse(_jumlahController.text);
      
      final success = await SimpananService.tambahSimpanan(
        widget.user['id'],
        'wajib',
        jumlah,
      );

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Simpanan berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menambah simpanan')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah simpanan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }
}