import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import '../services/api_service.dart';
import '../services/riwayat_pinjaman_service.dart';
import '../utils/format.dart';
import 'form_pengajuan_pinjaman_page.dart';

class PinjamanAnggotaPage extends StatefulWidget {
  final String username;

  const PinjamanAnggotaPage({super.key, required this.username});

  @override
  State<PinjamanAnggotaPage> createState() => _PinjamanAnggotaPageState();
}

class _PinjamanAnggotaPageState extends State<PinjamanAnggotaPage> {
  List<dynamic> _pengajuanList = [];
  List<dynamic> _pinjamanList = [];
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = DummyUsers.getUserByUsername(widget.username);
    if (user != null) {
      // Load pengajuan dan pinjaman dari database via API
      final pengajuanData = await ApiService.getPengajuan('anggota', user.id!);
      final pinjamanData = await RiwayatPinjamanService.getRiwayatByUserId(user.id!);
      
      setState(() {
        _pengajuanList = pengajuanData;
        _pinjamanList = pinjamanData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = DummyUsers.getUserByUsername(widget.username);

    return Scaffold(
      appBar: AppBar(title: const Text('Pinjaman Saya')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FormPengajuanPinjamanPage(
                username: widget.username,
              ),
            ),
          );
          _loadData();
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajukan Pinjaman',
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Tab Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedIndex = 0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _selectedIndex == 0 ? Colors.blue : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Pengajuan (${_pengajuanList.length})',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                                    color: _selectedIndex == 0 ? Colors.blue : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedIndex = 1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: _selectedIndex == 1 ? Colors.blue : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Pinjaman Aktif (${_pinjamanList.length})',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                                    color: _selectedIndex == 1 ? Colors.blue : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: _selectedIndex == 0 ? _buildPengajuanList() : _buildPinjamanList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPengajuanList() {
    return _pengajuanList.isEmpty
        ? const Center(child: Text('Belum ada pengajuan'))
        : ListView.builder(
            itemCount: _pengajuanList.length,
            itemBuilder: (context, index) {
              final p = _pengajuanList[index];
              return Card(
                child: ListTile(
                  title: Text('${p['nama_produk']} - ${Format.currency(double.tryParse(p['jumlah'].toString()) ?? 0)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tenor: ${p['tenor']} bulan'),
                      Text('Status: ${p['status']}'),
                      Text('Tanggal: ${Format.tanggal(p['tanggal_pengajuan'])}'),
                      Text('Keperluan: ${p['keperluan']}'),
                    ],
                  ),
                  trailing: _getStatusIcon(p['status']),
                ),
              );
            },
          );
  }

  Widget _buildPinjamanList() {
    return _pinjamanList.isEmpty
        ? const Center(child: Text('Belum ada pinjaman aktif'))
        : ListView.builder(
            itemCount: _pinjamanList.length,
            itemBuilder: (context, index) {
              final p = _pinjamanList[index];
              return Card(
                child: ListTile(
                  title: Text('Pinjaman - ${Format.currency(double.tryParse(p['jumlah'].toString()) ?? 0)}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tenor: ${p['tenor']} bulan'),
                      Text('Status: ${p['status']}'),
                      Text('Tanggal: ${Format.tanggal(p['tanggal'])}'),
                      if (p['total_cicilan'] != null)
                        Text('Total Cicilan: ${Format.currency(double.tryParse(p['total_cicilan'].toString()) ?? 0)}'),
                    ],
                  ),
                  trailing: _getStatusIcon(p['status']),
                ),
              );
            },
          );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'diproses_admin':
        return const Icon(Icons.admin_panel_settings, color: Colors.blue);
      case 'menunggu_approval':
        return const Icon(Icons.approval, color: Colors.purple);
      case 'disetujui':
      case 'aktif':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'ditolak':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'lunas':
        return const Icon(Icons.done_all, color: Colors.blue);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }
}