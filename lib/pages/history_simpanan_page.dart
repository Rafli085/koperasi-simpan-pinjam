import 'package:flutter/material.dart';
import '../services/simpanan_service.dart';
import '../models/simpanan_model.dart';
import '../utils/format.dart';

class HistorySimpananPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const HistorySimpananPage({super.key, required this.user});

  @override
  State<HistorySimpananPage> createState() => _HistorySimpananPageState();
}

class _HistorySimpananPageState extends State<HistorySimpananPage> {
  List<Simpanan> _simpananList = [];
  bool _isLoading = true;
  double _totalSimpanan = 0;

  @override
  void initState() {
    super.initState();
    _loadSimpanan();
  }

  Future<void> _loadSimpanan() async {
    setState(() => _isLoading = true);
    try {
      final simpananList = await SimpananService.getSimpananByUser(widget.user['id']);
      final total = await SimpananService.getTotalSimpanan(widget.user['id']);
      
      if (mounted) {
        setState(() {
          _simpananList = simpananList;
          _totalSimpanan = total;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Simpanan ${widget.user['nama']}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                Card(
                  margin: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.user['nama'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.savings, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Total Simpanan: ${Format.currency(_totalSimpanan)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.receipt, color: Colors.green),
                            const SizedBox(width: 8),
                            Text('${_simpananList.length} transaksi'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // History List
                Expanded(
                  child: _simpananList.isEmpty
                      ? const Center(child: Text('Belum ada riwayat simpanan'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _simpananList.length,
                          itemBuilder: (context, index) {
                            final simpanan = _simpananList[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                                title: Text(
                                  Format.currency(simpanan.jumlah),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                subtitle: Text(
                                  Format.tanggal(simpanan.tanggal.toString()),
                                ),
                                trailing: Text(
                                  'SIMPANAN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}