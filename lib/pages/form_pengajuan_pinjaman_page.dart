import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/dummy_users.dart';
import '../services/api_service.dart';
import '../services/notifikasi_service.dart';
import '../services/riwayat_pinjaman_service.dart';
import '../utils/format.dart';

class FormPengajuanPinjamanPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  final String? username; // Optional untuk backward compatibility

  const FormPengajuanPinjamanPage({super.key, this.user, this.username});

  @override
  State<FormPengajuanPinjamanPage> createState() =>
      _FormPengajuanPinjamanPageState();
}

class _FormPengajuanPinjamanPageState extends State<FormPengajuanPinjamanPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _nomorAnggotaController = TextEditingController();
  final _lamaAnggotaController = TextEditingController();
  final _namaBarangController = TextEditingController();
  final _hargaBarangController = TextEditingController();
  final _jumlahPinjamanController = TextEditingController();
  final _tenorController = TextEditingController();

  // Form values
  String? _produkPinjaman;
  String? _tujuanPinjaman = 'tunai';

  // Calculated values
  double _maksimalPinjaman = 0;
  double _hargaBarang = 0;
  int _lamaAnggota = 0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (widget.user != null) {
      _namaController.text = widget.user!['nama'] ?? '';
      _nomorAnggotaController.text = widget.user!['nomorAnggota'] ?? '';
      // Simulasi lama anggota berdasarkan user
      _lamaAnggota = widget.user!['username'] == 'anggota1' ? 5 : 2;
      _lamaAnggotaController.text = _lamaAnggota.toString();
    }
  }

  void _hitungMaksimalPinjaman() {
    if (_produkPinjaman == null) return;

    setState(() {
      if (_produkPinjaman == 'Pinjaman Tunai' || _produkPinjaman == 'Beli HP') {
        if (_lamaAnggota >= 5) {
          _maksimalPinjaman = 20000000;
        } else if (_lamaAnggota >= 3) {
          _maksimalPinjaman = 10000000;
        } else if (_lamaAnggota >= 1) {
          _maksimalPinjaman = 5000000;
        } else {
          _maksimalPinjaman = 0;
        }
      } else if (_produkPinjaman == 'Pinjaman Flexi') {
        _maksimalPinjaman = 2000000;
      }
    });
  }

  double _hitungMaksimalTunai() {
    if (_tujuanPinjaman == 'pembelian_barang') {
      // Untuk pembelian barang, maksimal pinjaman = limit maksimal (bukan dikurangi harga barang)
      return _maksimalPinjaman;
    }
    return _maksimalPinjaman;
  }

  String? _validateJumlahPinjaman(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan jumlah pinjaman';
    }

    final jumlah = double.tryParse(value);
    if (jumlah == null || jumlah <= 0) {
      return 'Jumlah pinjaman tidak valid';
    }

    final maksimalTunai = _hitungMaksimalTunai();
    if (jumlah > maksimalTunai) {
      return 'Melebihi batas maksimal: ${Format.currency(maksimalTunai)}';
    }

    return null;
  }

  String? _validateTenor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan tenor pinjaman';
    }

    final tenor = int.tryParse(value);
    if (tenor == null || tenor <= 0) {
      return 'Tenor tidak valid';
    }

    if (_produkPinjaman == 'Pinjaman Tunai' || _produkPinjaman == 'Beli HP') {
      if (tenor < 10) {
        return 'Tenor minimal 10 bulan untuk Pinjaman Tunai/Beli HP';
      }
    }

    return null;
  }

  void _submitPengajuan() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.user == null) return;

    setState(() => _isLoading = true);

    // Mapping produk_id berdasarkan jenis produk
    int produkId;
    switch (_produkPinjaman) {
      case 'Pinjaman Tunai':
        produkId = 1;
        break;
      case 'Pinjaman Flexi':
        produkId = 2;
        break;
      case 'Beli HP':
        produkId = 3;
        break;
      default:
        produkId = 1;
    }

    // Submit ke database via API
    final result = await ApiService.ajukanPinjaman(
      userId: int.parse(widget.user!['id'].toString()),
      produkId: produkId,
      jumlah: double.parse(_jumlahPinjamanController.text),
      tenor: int.parse(_tenorController.text),
      keperluan: _produkPinjaman == 'Beli HP' ? 'Pembelian HP ${_namaBarangController.text}' :
                (_produkPinjaman == 'Pinjaman Flexi' ? 'Pinjaman Flexi' : 
                (_tujuanPinjaman == 'tunai' ? 'Pinjaman tunai' : 'Pembelian ${_namaBarangController.text}')),
      merkHp: _produkPinjaman == 'Beli HP' ? _namaBarangController.text : 
             (_tujuanPinjaman == 'pembelian_barang' ? _namaBarangController.text : null),
      modelHp: _produkPinjaman == 'Beli HP' ? _namaBarangController.text : 
              (_tujuanPinjaman == 'pembelian_barang' ? _namaBarangController.text : null),
      hargaHp: _produkPinjaman == 'Beli HP' ? _hargaBarang : 
              (_tujuanPinjaman == 'pembelian_barang' ? _hargaBarang : null),
    );

    setState(() => _isLoading = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(result['success'] ? 'Pengajuan Berhasil' : 'Pengajuan Gagal'),
          content: Text(result['message']),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (result['success']) {
                  Navigator.pop(context);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengajuan Pinjaman')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Data Pribadi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Pribadi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomorAnggotaController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Anggota',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lamaAnggotaController,
                      decoration: const InputDecoration(
                        labelText: 'Lama Menjadi Anggota (tahun)',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _produkPinjaman,
                      decoration: const InputDecoration(
                        labelText: 'Produk Pinjaman',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pinjaman Tunai',
                          child: Text(
                            'Pinjaman Tunai (12% per tahun, min 10 bulan)',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Pinjaman Flexi',
                          child: Text(
                            'Pinjaman Flexi (5% per bulan, tenor bebas)',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Beli HP',
                          child: Text('Beli HP (12% per tahun, min 10 bulan)'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _produkPinjaman = value;
                          _hitungMaksimalPinjaman();
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Pilih produk pinjaman' : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Limit Pinjaman
            if (_maksimalPinjaman > 0)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Maksimal Pinjaman: ${Format.currency(_maksimalPinjaman)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Info Pinjaman Lain
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadPinjamanLain(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Text(
                                'Pinjaman Anggota Lain',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...snapshot.data!.take(3).map((p) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• ${p['nama']}: ${Format.currency(double.tryParse(p['jumlah'].toString()) ?? 0)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          )),
                          if (snapshot.data!.length > 3)
                            Text(
                              'dan ${snapshot.data!.length - 3} pinjaman lainnya...',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 16),

            // Detail Pengajuan
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Pengajuan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Khusus untuk Beli HP
                    if (_produkPinjaman == 'Beli HP') ...[
                      TextFormField(
                        controller: _namaBarangController,
                        decoration: const InputDecoration(
                          labelText: 'Merk HP',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Masukkan merk HP' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _hargaBarangController,
                        decoration: const InputDecoration(
                          labelText: 'Harga HP',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) {
                          setState(() {
                            _hargaBarang = double.tryParse(value) ?? 0;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan harga HP';
                          }
                          final harga = double.tryParse(value);
                          if (harga == null || harga <= 0) {
                            return 'Harga HP tidak valid';
                          }
                          if (harga > _maksimalPinjaman) {
                            return 'Harga HP melebihi limit pinjaman';
                          }
                          return null;
                        },
                      ),
                      if (_hargaBarang > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Harga HP: ${Format.currency(_hargaBarang)}\nMaksimal pinjaman: ${Format.currency(_maksimalPinjaman)}',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ] else ...[
                      // Untuk Pinjaman Tunai dan Flexi
                      const Text('Tujuan Pinjaman:'),
                      RadioListTile<String>(
                        title: const Text('Tunai'),
                        value: 'tunai',
                        groupValue: _tujuanPinjaman,
                        onChanged: (value) {
                          setState(() {
                            _tujuanPinjaman = value;
                            _hargaBarang = 0;
                            _hargaBarangController.clear();
                            _namaBarangController.clear();
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Pembelian Barang'),
                        value: 'pembelian_barang',
                        groupValue: _tujuanPinjaman,
                        onChanged: (value) {
                          setState(() => _tujuanPinjaman = value);
                        },
                      ),

                      // Detail Barang (jika pembelian barang)
                      if (_tujuanPinjaman == 'pembelian_barang') ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _namaBarangController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Barang',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (_tujuanPinjaman == 'pembelian_barang' &&
                                (value == null || value.isEmpty)) {
                              return 'Masukkan nama barang';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _hargaBarangController,
                          decoration: const InputDecoration(
                            labelText: 'Harga Barang',
                            border: OutlineInputBorder(),
                            prefixText: 'Rp ',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (value) {
                            setState(() {
                              _hargaBarang = double.tryParse(value) ?? 0;
                            });
                          },
                          validator: (value) {
                            if (_tujuanPinjaman == 'pembelian_barang') {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan harga barang';
                              }
                              final harga = double.tryParse(value);
                              if (harga == null || harga <= 0) {
                                return 'Harga barang tidak valid';
                              }
                              if (harga >= _maksimalPinjaman) {
                                return 'Harga barang melebihi limit pinjaman';
                              }
                            }
                            return null;
                          },
                        ),
                        if (_hargaBarang > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Harga barang: ${Format.currency(_hargaBarang)}\nMaksimal pinjaman: ${Format.currency(_maksimalPinjaman)}',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ],

                    const SizedBox(height: 16),

                    // Jumlah Pinjaman
                    TextFormField(
                      controller: _jumlahPinjamanController,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Pinjaman yang Diajukan',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validateJumlahPinjaman,
                    ),

                    const SizedBox(height: 16),

                    // Tenor
                    TextFormField(
                      controller: _tenorController,
                      decoration: const InputDecoration(
                        labelText: 'Tenor Pinjaman (bulan)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validateTenor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPengajuan,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Ajukan Pinjaman'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nomorAnggotaController.dispose();
    _lamaAnggotaController.dispose();
    _namaBarangController.dispose();
    _hargaBarangController.dispose();
    _jumlahPinjamanController.dispose();
    _tenorController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadPinjamanLain() async {
    if (widget.user == null) return [];
    final allPinjaman = await RiwayatPinjamanService.getAllRiwayat();
    return allPinjaman.where((p) => p['user_id'] != widget.user!['id'] && p['status'] == 'aktif').toList();
  }
}
