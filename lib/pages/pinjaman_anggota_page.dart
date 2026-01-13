import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/format.dart';
import '../utils/loan_calculator.dart';
import 'form_pengajuan_pinjaman_page.dart';

class PinjamanAnggotaPage extends StatefulWidget {
  final String? username; // Optional untuk backward compatibility
  
  const PinjamanAnggotaPage({super.key, this.username});

  @override
  State<PinjamanAnggotaPage> createState() => _PinjamanAnggotaPageState();
}

class _PinjamanAnggotaPageState extends State<PinjamanAnggotaPage> {
  User? user;
  List<dynamic> _pengajuanList = [];
  List<dynamic> _pinjamanList = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      print('Debug: userId from prefs = $userId');

      if (userId != null) {
        // Fetch users list to find current user
        final users = await ApiService.getUsers();
        print('Debug: users count = ${users.length}');
        
        final userData = users.firstWhere(
          (u) => u['id'] == userId,
          orElse: () => null,
        );
        print('Debug: userData = $userData');

        if (userData != null) {
          if (mounted) {
            setState(() {
              user = User.fromJson(userData);
            });
            print('Debug: user created = ${user?.nama}');
          }

          // Fetch pengajuan dan pinjaman
          final pengajuanResult = await ApiService.getPengajuan('anggota', userId);
          final pinjamanResult = await ApiService.getPinjaman(userId: userId);
          
          if (mounted) {
            setState(() {
              _pengajuanList = pengajuanResult;
              if (pinjamanResult['success']) {
                _pinjamanList = pinjamanResult['data'];
              }
            });
          }
        }
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
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
      appBar: AppBar(title: const Text('Pinjaman Saya')),
      body: _isLoading
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print('Debug: user = $user');
          print('Debug: user?.id = ${user?.id}');
          
          if (user != null && user!.id != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormPengajuanPinjamanPage(
                  user: {
                    'id': user!.id,
                    'nama': user!.nama,
                    'username': user!.username,
                    'nomorAnggota': user!.nomorAnggota ?? '',
                  },
                ),
              ),
            ).then((_) => _loadData());
          } else {
            print('Debug: User data tidak tersedia');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data user belum siap. User: $user')),
            );
          }
        },
        label: const Text('Ajukan Pinjaman'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPengajuanList() {
    return _pengajuanList.isEmpty
        ? const Center(child: Text('Belum ada pengajuan'))
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _pengajuanList.length,
            itemBuilder: (context, index) {
              final p = _pengajuanList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${p['nama_produk']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          _getStatusIcon(p['status']),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Format.currency(double.tryParse(p['jumlah'].toString()) ?? 0),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tenor: ${p['tenor']} bulan'),
                                Text('Status: ${p['status']}'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tanggal: ${Format.tanggal(p['tanggal_pengajuan'])}'),
                                Text('Keperluan: ${p['keperluan']}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildPinjamanList() {
    return _pinjamanList.isEmpty
        ? const Center(child: Text('Belum ada pinjaman aktif'))
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _pinjamanList.length,
            itemBuilder: (context, index) {
              final p = _pinjamanList[index];
              final principal = double.tryParse(p['jumlah'].toString()) ?? 0;
              final tenor = int.tryParse(p['tenor'].toString()) ?? 0;
              final productName = p['nama_produk'] ?? 'Pinjaman Tunai';
              
              // Calculate loan details with interest
              final loanDetails = LoanCalculator.calculateLoanDetails(
                principal: principal,
                tenor: tenor,
                productType: productName,
              );
              
              final totalAmount = loanDetails['total']!;
              final interest = loanDetails['interest']!;
              final monthlyPayment = loanDetails['monthlyPayment']!;
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.credit_card, color: Colors.white),
                  ),
                  title: Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ${Format.currency(totalAmount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      Text('Status: ${p['status']} • ${p['tenor']} bulan'),
                    ],
                  ),
                  trailing: _getStatusIcon(p['status']),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Pinjaman Pokok:'),
                              Text(
                                Format.currency(principal),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bunga (${LoanCalculator.getInterestRateText(productName)}):'),
                              Text(
                                Format.currency(interest),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Harus Dibayar:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                Format.currency(totalAmount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Cicilan per Bulan:'),
                              Text(
                                Format.currency(monthlyPayment),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tanggal Pinjam: ${Format.tanggal(p['tanggal'])}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
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
