import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/currency_formatter.dart';

class HistoryCicilanPage extends StatefulWidget {
  final int? userId; // null untuk admin (lihat semua), ada nilai untuk anggota
  final String title;

  const HistoryCicilanPage({
    Key? key,
    this.userId,
    required this.title,
  }) : super(key: key);

  @override
  State<HistoryCicilanPage> createState() => _HistoryCicilanPageState();
}

class _HistoryCicilanPageState extends State<HistoryCicilanPage> {
  List<dynamic> historyCicilan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response = await ApiService.getHistoryCicilan(userId: widget.userId);
      setState(() {
        historyCicilan = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : historyCicilan.isEmpty
              ? Center(child: Text('Belum ada history cicilan'))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: historyCicilan.length,
                  itemBuilder: (context, index) {
                    final cicilan = historyCicilan[index];
                    final jumlah = double.tryParse(cicilan['jumlah'].toString()) ?? 0;
                    final tanggal = cicilan['tanggal'] ?? '';
                    
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.payment, color: Colors.white),
                        ),
                        title: Text(CurrencyFormatter.format(jumlah)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.userId == null) // Tampilkan nama anggota untuk admin
                              Text('Anggota: ${cicilan['nama_anggota']}'),
                            Text('Produk: ${cicilan['nama_produk'] ?? 'Unknown'}'),
                            Text('Tanggal: $tanggal'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editCicilan(cicilan),
                              tooltip: 'Edit Cicilan',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _hapusCicilan(cicilan),
                              tooltip: 'Hapus Cicilan',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _editCicilan(Map<String, dynamic> cicilan) {
    final jumlahController = TextEditingController(
      text: cicilan['jumlah'].toString(),
    );
    DateTime selectedDate = DateTime.tryParse(cicilan['tanggal']) ?? DateTime.now();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Cicilan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: jumlahController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Cicilan',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Tanggal: '),
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
                if (jumlahController.text.isEmpty) return;
                
                Navigator.pop(context);
                
                final result = await ApiService.editCicilan(
                  cicilan['id'],
                  double.tryParse(jumlahController.text) ?? 0,
                  selectedDate,
                );
                
                if (result['success']) {
                  _loadHistory();
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
      ),
    );
  }

  void _hapusCicilan(Map<String, dynamic> cicilan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Cicilan'),
        content: Text('Apakah Anda yakin ingin menghapus cicilan sebesar ${CurrencyFormatter.format(double.tryParse(cicilan['jumlah'].toString()) ?? 0)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final result = await ApiService.hapusCicilan(cicilan['id']);
              
              if (result['success']) {
                _loadHistory();
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
}