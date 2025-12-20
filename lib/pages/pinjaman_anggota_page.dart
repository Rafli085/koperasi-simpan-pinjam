import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import '../services/api_service.dart';
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
        child: const Icon(Icons.add),
        tooltip: 'Ajukan Pinjaman',
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Riwayat Pengajuan',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
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
                                    title: Text('Pinjaman - ${Format.currency(1000000)}'),
                                    subtitle: const Text('Status: Belum ada data'),
                                    trailing: const Icon(Icons.help, color: Colors.grey),
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