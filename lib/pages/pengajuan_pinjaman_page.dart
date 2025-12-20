import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/produk_model.dart';
import '../utils/format.dart';

class PengajuanPinjamanPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const PengajuanPinjamanPage({Key? key, required this.user}) : super(key: key);

  @override
  State<PengajuanPinjamanPage> createState() => _PengajuanPinjamanPageState();
}

class _PengajuanPinjamanPageState extends State<PengajuanPinjamanPage> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _tenorController = TextEditingController();
  final _keperluanController = TextEditingController();
  final _merkHpController = TextEditingController();
  final _modelHpController = TextEditingController();
  final _hargaHpController = TextEditingController();

  List<ProdukKoperasi> _produkList = [];
  ProdukKoperasi? _selectedProduk;
  double _limitMaksimal = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  Future<void> _loadProduk() async {
    final data = await ApiService.getProduk();
    setState(() {
      _produkList = data.map((e) => ProdukKoperasi.fromJson(e)).toList();
    });
  }

  Future<void> _calculateLimit() async {
    if (_selectedProduk == null) return;
    
    final result = await ApiService.calculateLimit(
      int.parse(widget.user['id'].toString()),
      _selectedProduk!.id,
    );
    
    if (result['success']) {
      setState(() {
        _limitMaksimal = double.parse(result['limit_maksimal'].toString());
      });
    }
  }

  Future<void> _submitPengajuan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.ajukanPinjaman(
      userId: int.parse(widget.user['id'].toString()),
      produkId: _selectedProduk!.id,
      jumlah: double.parse(_jumlahController.text),
      tenor: int.parse(_tenorController.text),
      keperluan: _keperluanController.text,
      merkHp: _selectedProduk!.jenis == 'jual_hp' ? _merkHpController.text : null,
      modelHp: _selectedProduk!.jenis == 'jual_hp' ? _modelHpController.text : null,
      hargaHp: _selectedProduk!.jenis == 'jual_hp' ? double.parse(_hargaHpController.text) : null,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengajuan Pinjaman')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<ProdukKoperasi>(
              value: _selectedProduk,
              decoration: InputDecoration(labelText: 'Jenis Produk'),
              items: _produkList.map((produk) {
                return DropdownMenuItem(
                  value: produk,
                  child: Text('${produk.namaProduk} (${produk.bungaPersen}%/${produk.bungaPer})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedProduk = value);
                _calculateLimit();
              },
              validator: (value) => value == null ? 'Pilih produk' : null,
            ),
            
            if (_limitMaksimal > 0) ...[
              SizedBox(height: 8),
              Text('Limit Maksimal: ${Format.currency(_limitMaksimal)}', 
                   style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],

            SizedBox(height: 16),
            TextFormField(
              controller: _jumlahController,
              decoration: InputDecoration(labelText: 'Jumlah Pinjaman'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Masukkan jumlah';
                final jumlah = double.tryParse(value!);
                if (jumlah == null || jumlah <= 0) return 'Jumlah tidak valid';
                if (_limitMaksimal > 0 && jumlah > _limitMaksimal) return 'Melebihi limit maksimal';
                return null;
              },
            ),

            SizedBox(height: 16),
            TextFormField(
              controller: _tenorController,
              decoration: InputDecoration(labelText: 'Tenor (bulan)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Masukkan tenor';
                final tenor = int.tryParse(value!);
                if (tenor == null || tenor <= 0) return 'Tenor tidak valid';
                if (_selectedProduk?.tenorMin != null && tenor < _selectedProduk!.tenorMin!) {
                  return 'Tenor minimal ${_selectedProduk!.tenorMin} bulan';
                }
                return null;
              },
            ),

            if (_selectedProduk?.jenis == 'jual_hp') ...[
              SizedBox(height: 16),
              TextFormField(
                controller: _merkHpController,
                decoration: InputDecoration(labelText: 'Merk HP'),
                validator: (value) => value?.isEmpty ?? true ? 'Masukkan merk HP' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _modelHpController,
                decoration: InputDecoration(labelText: 'Model HP'),
                validator: (value) => value?.isEmpty ?? true ? 'Masukkan model HP' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _hargaHpController,
                decoration: InputDecoration(labelText: 'Harga HP'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Masukkan harga HP';
                  final harga = double.tryParse(value!);
                  if (harga == null || harga <= 0) return 'Harga tidak valid';
                  return null;
                },
              ),
            ],

            SizedBox(height: 16),
            TextFormField(
              controller: _keperluanController,
              decoration: InputDecoration(labelText: 'Keperluan'),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Masukkan keperluan' : null,
            ),

            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPengajuan,
              child: _isLoading ? CircularProgressIndicator() : Text('Ajukan Pinjaman'),
            ),
          ],
        ),
      ),
    );
  }
}