import 'package:flutter/material.dart';
import 'simpanan_admin_page.dart';
import 'pinjaman_admin_page.dart';
import 'kelola_anggota_page.dart';
import 'approval_pinjaman_page.dart';
import 'dashboard_statistik_page.dart';
import 'event_admin_page.dart';
import 'notifikasi_pengajuan_page.dart';
import '../services/api_service.dart';
import '../services/notifikasi_service.dart';
import '../data/dummy_users.dart';

class DashboardAdmin extends StatefulWidget {
  final VoidCallback onLogout;
  final String role;
  final String username;

  const DashboardAdmin({
    super.key,
    required this.onLogout,
    required this.role,
    required this.username,
  });

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _pengajuanBaruCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPengajuanBaru();
  }

  Future<void> _loadPengajuanBaru() async {
    final user = DummyUsers.getUserByUsername(widget.username);
    if (user != null) {
      final pengajuan = await ApiService.getPengajuanBaru(role: user.role);
      setState(() {
        _pengajuanBaruCount = pengajuan.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Admin (${widget.role})'),
        actions: [
          // Notifikasi pengajuan baru
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotifikasiPengajuanPage(username: widget.username),
                    ),
                  );
                  _loadPengajuanBaru(); // Refresh setelah kembali
                },
              ),
              if (_pengajuanBaruCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_pengajuanBaruCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== STATISTIK =====
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blue),
              title: const Text('Dashboard Statistik'),
              subtitle: const Text('Ringkasan kondisi koperasi'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardStatistikPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ===== NOTIFIKASI PENGAJUAN =====
          Card(
            color: _pengajuanBaruCount > 0 ? Colors.red[50] : Colors.grey[50],
            child: ListTile(
              leading: Stack(
                children: [
                  Icon(
                    Icons.notifications,
                    color: _pengajuanBaruCount > 0 ? Colors.red : Colors.grey,
                  ),
                  if (_pengajuanBaruCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$_pengajuanBaruCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                'Pengajuan Pinjaman',
                style: TextStyle(
                  fontWeight: _pengajuanBaruCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                _pengajuanBaruCount > 0
                    ? '$_pengajuanBaruCount pengajuan belum dibaca'
                    : 'Semua pengajuan sudah dibaca',
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotifikasiPengajuanPage(username: widget.username),
                  ),
                );
                _loadPengajuanBaru();
              },
            ),
          ),

          const SizedBox(height: 12),

          // ===== SIMPANAN =====
          Card(
            child: ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Data Simpanan'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SimpananAdminPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ===== PINJAMAN =====
          Card(
            child: ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Data Pinjaman'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PinjamanAdminPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          if (widget.role == 'ketua') ...[
            Card(
              color: Colors.orange[50],
              child: ListTile(
                leading:
                    const Icon(Icons.verified, color: Colors.orange),
                title: const Text('Approval Pinjaman'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ApprovalPinjamanPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ===== ANGGOTA =====
          Card(
            child: ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Kelola Anggota'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const KelolaAnggotaPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ===== EVENT =====
          Card(
            color: Colors.purple[50],
            child: ListTile(
              leading: const Icon(Icons.event, color: Colors.purple),
              title: const Text('Kelola Event'),
              subtitle: const Text('Pengumuman dan polling untuk anggota'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EventAdminPage(),
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
