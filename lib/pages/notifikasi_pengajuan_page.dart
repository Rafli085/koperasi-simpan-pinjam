import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notifikasi_service.dart';
import '../services/riwayat_pinjaman_service.dart';
import '../utils/format.dart';
import '../data/dummy_users.dart';

class NotifikasiPengajuanPage extends StatefulWidget {
  final String username;

  const NotifikasiPengajuanPage({super.key, required this.username});

  @override
  State<NotifikasiPengajuanPage> createState() =>
      _NotifikasiPengajuanPageState();
}

class _NotifikasiPengajuanPageState extends State<NotifikasiPengajuanPage> {
  List<dynamic> _pengajuanBaru = [];
  bool _isLoading = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
    _loadPengajuanBaru();
  }

  void _getUserRole() {
    final user = DummyUsers.getUserByUsername(widget.username);
    _userRole = user?.role;
  }

  Future<void> _loadPengajuanBaru() async {
    setState(() => _isLoading = true);
    // Load dari database via API berdasarkan role
    final data = await ApiService.getPengajuanBaru(role: _userRole);
    setState(() {
      _pengajuanBaru = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Baru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPengajuanBaru,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pengajuanBaru.isEmpty
          ? const Center(child: Text('Tidak ada pengajuan baru'))
          : ListView.builder(
              itemCount: _pengajuanBaru.length,
              itemBuilder: (context, index) {
                final pengajuan = _pengajuanBaru[index];
                final dibaca = pengajuan['dibaca'] ?? false;

                return Card(
                  margin: const EdgeInsets.all(8),
                  color: dibaca ? Colors.grey.shade100 : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      dibaca ? Icons.mark_email_read : Icons.mark_email_unread,
                      color: dibaca ? Colors.grey : Colors.orange,
                    ),
                    title: Text(
                      '${pengajuan['nama_anggota']}',
                      style: TextStyle(
                        fontWeight: dibaca
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Produk: ${pengajuan['nama_produk']}'),
                        Text(
                          'Jumlah: ${Format.currency(double.tryParse(pengajuan['jumlah'].toString()) ?? 0)}',
                        ),
                        Text('Tenor: ${pengajuan['tenor']} bulan'),
                        Text(
                          'Tanggal: ${Format.tanggal(pengajuan['tanggal_pengajuan'])}',
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(pengajuan['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(pengajuan['status']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Detail
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => _showDetailPengajuan(pengajuan),
                        ),
                        // Tombol Hapus (untuk admin dan ketua)
                        if (_userRole == 'admin_keuangan' ||
                            _userRole == 'ketua')
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _hapusPengajuan(pengajuan),
                            tooltip: 'Hapus Pengajuan',
                          ),
                        // Tombol berdasarkan status dan role
                        if (_userRole == 'admin_keuangan' &&
                            pengajuan['status'] == 'pending')
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.blue),
                            onPressed: () => _prosesToKetua(pengajuan),
                            tooltip: 'Teruskan ke Ketua',
                          )
                        else if (_userRole == 'ketua' &&
                            pengajuan['status'] == 'diproses_admin')
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Setujui'),
                                onPressed: () =>
                                    _approveKetua(pengajuan, 'disetujui'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Tolak'),
                                onPressed: () =>
                                    _approveKetua(pengajuan, 'ditolak'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          )
                        else if (_userRole == 'admin_keuangan' &&
                            pengajuan['status'] == 'disetujui')
                          IconButton(
                            icon: const Icon(
                              Icons.add_business,
                              color: Colors.blue,
                            ),
                            onPressed: () => _prosesKePinjaman(pengajuan),
                            tooltip: 'Proses ke Pinjaman',
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _prosesToKetua(Map<String, dynamic> pengajuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Teruskan ke Ketua'),
        content: Text(
          'Apakah Anda ingin meneruskan pengajuan dari ${pengajuan['nama_anggota']} ke ketua untuk persetujuan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final result = await ApiService.prosesAdmin(pengajuan['id']);

              _loadPengajuanBaru();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: result['success']
                      ? Colors.green
                      : Colors.red,
                ),
              );
            },
            child: const Text('Teruskan'),
          ),
        ],
      ),
    );
  }

  void _approveKetua(Map<String, dynamic> pengajuan, String status) {
    final isApprove = status == 'disetujui';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Setujui Pengajuan' : 'Tolak Pengajuan'),
        content: Text(
          'Apakah Anda yakin ingin ${isApprove ? 'menyetujui' : 'menolak'} pengajuan dari ${pengajuan['nama_anggota']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final result = await ApiService.approveKetua(
                pengajuan['id'],
                status,
              );

              _loadPengajuanBaru();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: result['success']
                      ? Colors.green
                      : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isApprove ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );
  }

  void _prosesKePinjaman(Map<String, dynamic> pengajuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Proses ke Pinjaman'),
        content: Text(
          'Apakah Anda ingin memproses pengajuan yang sudah disetujui dari ${pengajuan['nama_anggota']} menjadi pinjaman aktif?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Disable tombol sementara untuk mencegah double click
              setState(() {
                // Bisa tambah loading state jika perlu
              });

              try {
                final result = await ApiService.prosesKePinjaman(
                  pengajuan['id'],
                );

                _loadPengajuanBaru();

                // Cek response dengan benar
                final isSuccess = result['success'] == true;
                final message = result['message'] ?? (isSuccess ? 'Proses berhasil' : 'Proses gagal');
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: isSuccess ? Colors.green : Colors.red,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Proses'),
          ),
        ],
      ),
    );
  }

  void _showDetailPengajuan(Map<String, dynamic> pengajuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Pengajuan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${pengajuan['nama_anggota']}'),
            Text('Produk: ${pengajuan['nama_produk']}'),
            Text(
              'Jumlah: ${Format.currency(double.tryParse(pengajuan['jumlah'].toString()) ?? 0)}',
            ),
            Text('Tenor: ${pengajuan['tenor']} bulan'),
            Text('Keperluan: ${pengajuan['keperluan']}'),
            if (pengajuan['nama_barang'] != null)
              Text('Barang: ${pengajuan['nama_barang']}'),
            if (pengajuan['harga_barang'] != null)
              Text(
                'Harga Barang: ${Format.currency(double.tryParse(pengajuan['harga_barang'].toString()) ?? 0)}',
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _hapusPengajuan(Map<String, dynamic> pengajuan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengajuan'),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengajuan dari ${pengajuan['nama_anggota']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final result = await ApiService.hapusPengajuan(pengajuan['id']);

              _loadPengajuanBaru();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message']),
                  backgroundColor: result['success']
                      ? Colors.green
                      : Colors.red,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'diproses_admin':
        return Colors.blue;
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu Review';
      case 'diproses_admin':
        return 'Menunggu Persetujuan';
      case 'disetujui':
        return 'Disetujui - Siap Diproses';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }
}
