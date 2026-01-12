import 'package:flutter/material.dart';
import '../services/riwayat_pinjaman_service.dart';
import '../services/api_service.dart';
import '../utils/format.dart';

class PinjamanAdminPage extends StatefulWidget {
  const PinjamanAdminPage({super.key});

  @override
  State<PinjamanAdminPage> createState() => _PinjamanAdminPageState();
}

class _PinjamanAdminPageState extends State<PinjamanAdminPage> {
  List<Map<String, dynamic>> _pinjamanList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPinjaman();
  }

  Future<void> _loadPinjaman() async {
    setState(() => _isLoading = true);
    final data = await RiwayatPinjamanService.getAllRiwayat();
    setState(() {
      _pinjamanList = data;
      _isLoading = false;
    });
  }

  void _editPinjaman(Map<String, dynamic> pinjaman) {
    final jumlahController = TextEditingController(
      text: pinjaman['jumlah'].toString(),
    );
    final tenorController = TextEditingController(
      text: pinjaman['tenor'].toString(),
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Pinjaman ${pinjaman['nama']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: jumlahController,
              decoration: const InputDecoration(
                labelText: 'Jumlah Pinjaman',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tenorController,
              decoration: const InputDecoration(
                labelText: 'Tenor (bulan)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final result = await ApiService.editPinjaman(
                pinjaman['id'],
                double.tryParse(jumlahController.text) ?? 0,
                int.tryParse(tenorController.text) ?? 0,
              );
              
              if (result['success']) {
                _loadPinjaman();
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: result['success'] ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _hapusPinjaman(Map<String, dynamic> pinjaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pinjaman'),
        content: Text('Apakah Anda yakin ingin menghapus pinjaman ${pinjaman['nama']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final result = await ApiService.hapusPinjaman(pinjaman['id']);
              
              if (result['success']) {
                _loadPinjaman();
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: result['success'] ? Colors.green : Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pinjaman Anggota'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pinjamanList.isEmpty
              ? const Center(child: Text('Belum ada data pinjaman'))
              : ListView.builder(
                  itemCount: _pinjamanList.length,
                  itemBuilder: (context, index) {
                    final p = _pinjamanList[index];
                    final jumlah = double.tryParse(p['jumlah'].toString()) ?? 0;
                    final totalCicilan = double.tryParse(p['total_cicilan'].toString()) ?? 0;
                    final sisa = jumlah - totalCicilan;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.credit_card),
                        title: Text(Format.currency(jumlah)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nama: ${p['nama']}'),
                            const SizedBox(height: 4),
                            Text('Tanggal Pinjam: ${Format.tanggal(p['tanggal'])}'),
                            const SizedBox(height: 4),
                            Text('Tenor: ${p['tenor']} bulan'),
                            const SizedBox(height: 4),
                            Text('Status: ${p['status']} • Sisa: ${Format.currency(sisa)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(p['status']),
                              backgroundColor: _statusColor(p['status']),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editPinjaman(p),
                              tooltip: 'Edit Pinjaman',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusPinjaman(p),
                              tooltip: 'Hapus Pinjaman',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color? _statusColor(String status) {
    switch (status) {
      case 'aktif':
        return Colors.green[100];
      case 'menunggu':
        return Colors.orange[100];
      case 'ditolak':
        return Colors.red[100];
      case 'lunas':
        return Colors.blue[100];
      default:
        return null;
    }
  }
}