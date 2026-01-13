import 'package:flutter/material.dart';
import '../data/dummy_users.dart';
import '../services/api_service.dart';
import 'tambah_anggota_page.dart';

class KelolaAnggotaPage extends StatefulWidget {
  const KelolaAnggotaPage({super.key});

  @override
  State<KelolaAnggotaPage> createState() => _KelolaAnggotaPageState();
}

class _KelolaAnggotaPageState extends State<KelolaAnggotaPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await ApiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  void _editAnggota(Map<String, dynamic> user) {
    final namaController = TextEditingController(text: user['nama']);
    final usernameController = TextEditingController(text: user['username']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Anggota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ApiService.editUser(
                user['id'],
                usernameController.text,
                namaController.text,
              );
              if (result['success']) {
                _loadUsers();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['message'])),
              );
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _hapusAnggota(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Anggota'),
        content: Text('Apakah Anda yakin ingin menghapus ${user['nama']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ApiService.deleteUser(user['id']);
              if (result['success']) {
                _loadUsers();
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result['message'])),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kelola Anggota')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final query = _searchController.text.toLowerCase();
    final anggota = _users
        .where(
          (user) =>
              user['role'] == 'anggota' &&
              (user['nama'].toLowerCase().contains(query) ||
                  user['username'].toLowerCase().contains(query)),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Anggota')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahAnggotaPage()),
          );
          if (result == true) {
            _loadUsers(); // Refresh data dari database
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Cari Anggota',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: anggota.isEmpty
                ? const Center(child: Text('Tidak ada anggota ditemukan'))
                : ListView.builder(
                    itemCount: anggota.length,
                    itemBuilder: (context, index) {
                      final user = anggota[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(user['nama']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Username: ${user['username']}'),
                              if (user['nomorAnggota'] != null)
                                Text('No. Anggota: ${user['nomorAnggota']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editAnggota(user),
                                tooltip: 'Edit Anggota',
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _hapusAnggota(user),
                                tooltip: 'Hapus Anggota',
                              ),
                            ],
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
