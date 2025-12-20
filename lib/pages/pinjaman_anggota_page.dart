import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import '../services/pinjaman_service.dart';
import '../services/api_service.dart';
import '../models/pinjaman_model.dart';
import '../utils/format.dart';
import 'pengajuan_pinjaman_page.dart';

class PinjamanAnggotaPage extends StatefulWidget {
  final String username;

  const PinjamanAnggotaPage({super.key, required this.username});

  @override
  State<PinjamanAnggotaPage> createState() => _PinjamanAnggotaPageState();
}

class _PinjamanAnggotaPageState extends State<PinjamanAnggotaPage> {
  List<dynamic> _pengajuanList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPengajuan();
  }

  Future<void> _loadPengajuan() async {
    setState(() => _isLoading = true);
    final user = DummyUsers.getUserByUsername(widget.username);
    if (user != null) {
      final data = await ApiService.getPengajuan('anggota', user.id!);
      setState(() {
        _pengajuanList = data;
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
              builder: (context) => PengajuanPinjamanPage(
                user: {
                  'id': user?.id.toString() ?? '0',
                  'username': user?.username ?? '',
                  'nama': user?.nama ?? '',
                },
              ),
            ),
          );
          _loadPengajuan();
        },
        child: Icon(Icons.add),
        tooltip: 'Ajukan Pinjaman',
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Tab untuk Pengajuan dan Pinjaman Aktif
                    Container(
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('Riwayat Pengajuan', 
                                       style: Theme.of(context).textTheme.titleMedium),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _pengajuanList.isEmpty
                          ? const Center(child: Text('Belum ada pengajuan'))
                          : ListView.builder(
                              itemCount: _pengajuanList.length,
                              itemBuilder: (context, index) {
                                final p = _pengajuanList[index];
                                return Card(
                                  child: ListTile(
                                    title: Text('${p['nama_produk']} - ${Format.currency(double.parse(p['jumlah'].toString()))}'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Tenor: ${p['tenor']} bulan'),
                                        Text('Status: ${p['status']}'),
                                        Text('Tanggal: ${Format.tanggal(p['tanggal_pengajuan'])}'),
                                        if (p['keperluan'] != null) Text('Keperluan: ${p['keperluan']}'),
                                        if (p['catatan_admin'] != null) Text('Catatan Admin: ${p['catatan_admin']}'),
                                        if (p['catatan_ketua'] != null) Text('Catatan Ketua: ${p['catatan_ketua']}'),
                                      ],
                                    ),
                                    trailing: _getStatusIcon(p['status']),
                                    onTap: p['status'] == 'disetujui' ? () => _showPinjamanDetail(p) : null,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'diproses_admin':
        return Icon(Icons.admin_panel_settings, color: Colors.blue);
      case 'menunggu_approval':
        return Icon(Icons.approval, color: Colors.purple);
      case 'disetujui':
        return Icon(Icons.check_circle, color: Colors.green);
      case 'ditolak':
        return Icon(Icons.cancel, color: Colors.red);
      default:
        return Icon(Icons.help, color: Colors.grey);
    }
  }

  void _showPinjamanDetail(Map<String, dynamic> pengajuan) async {
    // Get pinjaman yang dibuat dari pengajuan ini
    final detailList = await ApiService.getDetailPinjaman(int.parse(widget.user['id'].toString()));
    final pinjaman = detailList.firstWhere(
      (p) => p['pengajuan_id'].toString() == pengajuan['id'].toString(),
      orElse: () => null,
    );
    
    if (pinjaman == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Pinjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Produk: ${pinjaman['nama_produk']}'),
            Text('Jumlah Pokok: ${Format.currency(double.parse(pinjaman['jumlah'].toString()))}'),
            Text('Bunga: ${Format.currency(double.parse(pinjaman['bunga'].toString()))}'),
            Text('Total Harus Bayar: ${Format.currency(double.parse(pinjaman['total_harus_bayar'].toString()))}'),
            Text('Total Cicilan: ${Format.currency(double.parse(pinjaman['total_cicilan'].toString()))}'),
            Text('Sisa Pinjaman: ${Format.currency(double.parse(pinjaman['sisa_pinjaman'].toString()))}'),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: pinjaman['status_lunas'] ? Colors.green.shade100 : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                pinjaman['status_lunas'] ? 'STATUS: LUNAS' : 'STATUS: BELUM LUNAS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: pinjaman['status_lunas'] ? Colors.green.shade800 : Colors.orange.shade800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
