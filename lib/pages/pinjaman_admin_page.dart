import 'package:flutter/material.dart';
import '../services/riwayat_pinjaman_service.dart';
import '../services/api_service.dart';
import '../utils/format.dart';
import '../utils/loan_calculator.dart';
import 'history_cicilan_page.dart';

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

  void _bayarCicilan(Map<String, dynamic> pinjaman) {
    final cicilanController = TextEditingController();
    final jumlahPinjaman = double.tryParse(pinjaman['jumlah'].toString()) ?? 0;
    DateTime selectedDate = DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Bayar Cicilan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Anggota: ${pinjaman['nama']}'),
              Text('Jumlah Pinjaman: ${Format.currency(jumlahPinjaman)}'),
              const SizedBox(height: 16),
              TextField(
                controller: cicilanController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Bayar',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Tanggal: '),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  ),
                ],
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
                if (cicilanController.text.isEmpty) return;
                
                Navigator.pop(context);
                
                final jumlahCicilan = int.tryParse(cicilanController.text) ?? 0;
                final result = await ApiService.bayarCicilanWithDate(
                  pinjaman['id'], 
                  jumlahCicilan,
                  selectedDate,
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
              child: const Text('Bayar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editPinjaman(Map<String, dynamic> pinjaman) {
    final jumlahController = TextEditingController(
      text: pinjaman['jumlah'].toString(),
    );
    final tenorController = TextEditingController(
      text: pinjaman['tenor'].toString(),
    );
    final cicilanController = TextEditingController();
    
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
            const SizedBox(height: 16),
            TextField(
              controller: cicilanController,
              decoration: const InputDecoration(
                labelText: 'Bayar Cicilan (opsional)',
                prefixText: 'Rp ',
                hintText: 'Kosongkan jika tidak ada cicilan',
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
              
              // Update pinjaman
              final editResult = await ApiService.editPinjaman(
                pinjaman['id'],
                double.tryParse(jumlahController.text) ?? 0,
                int.tryParse(tenorController.text) ?? 0,
              );
              
              // Bayar cicilan jika ada
              if (cicilanController.text.isNotEmpty) {
                final jumlahCicilan = int.tryParse(cicilanController.text) ?? 0;
                if (jumlahCicilan > 0) {
                  await ApiService.bayarCicilan(pinjaman['id'], jumlahCicilan);
                }
              }
              
              if (editResult['success']) {
                _loadPinjaman();
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(editResult['message']),
                  backgroundColor: editResult['success'] ? Colors.green : Colors.red,
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
                    final principal = double.tryParse(p['jumlah'].toString()) ?? 0;
                    final tenor = int.tryParse(p['tenor'].toString()) ?? 0;
                    final productName = p['nama_produk'] ?? 'Pinjaman Tunai';
                    final totalCicilan = double.tryParse(p['total_cicilan'].toString()) ?? 0;
                    
                    // Calculate loan details with interest
                    final loanDetails = LoanCalculator.calculateLoanDetails(
                      principal: principal,
                      tenor: tenor,
                      productType: productName,
                    );
                    
                    final totalAmount = loanDetails['total']!;
                    final sisa = totalAmount - totalCicilan;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p['nama'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        productName,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    p['status'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: _statusColor(p['status']),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Amount info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total: ${Format.currency(totalAmount)}'),
                                Text('Sisa: ${Format.currency(sisa)}'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionButton(
                                  Icons.history,
                                  'History',
                                  Colors.orange,
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HistoryCicilanPage(
                                        userId: null,
                                        title: 'History Cicilan - ${p['nama']}',
                                      ),
                                    ),
                                  ),
                                ),
                                _buildActionButton(
                                  Icons.payment,
                                  'Bayar',
                                  Colors.green,
                                  () => _bayarCicilan(p),
                                ),
                                _buildActionButton(
                                  Icons.edit,
                                  'Edit',
                                  Colors.blue,
                                  () => _editPinjaman(p),
                                ),
                                _buildActionButton(
                                  Icons.delete,
                                  'Hapus',
                                  Colors.red,
                                  () => _hapusPinjaman(p),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 20),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
          ),
        ),
      ],
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