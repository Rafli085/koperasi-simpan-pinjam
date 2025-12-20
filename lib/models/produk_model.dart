class ProdukKoperasi {
  final int id;
  final String namaProduk;
  final String jenis;
  final double bungaPersen;
  final String bungaPer;
  final int? tenorMin;
  final bool isActive;

  ProdukKoperasi({
    required this.id,
    required this.namaProduk,
    required this.jenis,
    required this.bungaPersen,
    required this.bungaPer,
    this.tenorMin,
    required this.isActive,
  });

  factory ProdukKoperasi.fromJson(Map<String, dynamic> json) {
    return ProdukKoperasi(
      id: int.parse(json['id'].toString()),
      namaProduk: json['nama_produk'] ?? '',
      jenis: json['jenis'] ?? '',
      bungaPersen: double.parse(json['bunga_persen'].toString()),
      bungaPer: json['bunga_per'] ?? 'tahun',
      tenorMin: json['tenor_min'] != null ? int.parse(json['tenor_min'].toString()) : null,
      isActive: json['is_active'] == '1' || json['is_active'] == 1,
    );
  }
}

class LimitPinjaman {
  final int id;
  final int produkId;
  final int masaAnggotaMinTahun;
  final double limitMaksimal;

  LimitPinjaman({
    required this.id,
    required this.produkId,
    required this.masaAnggotaMinTahun,
    required this.limitMaksimal,
  });

  factory LimitPinjaman.fromJson(Map<String, dynamic> json) {
    return LimitPinjaman(
      id: int.parse(json['id'].toString()),
      produkId: int.parse(json['produk_id'].toString()),
      masaAnggotaMinTahun: int.parse(json['masa_anggota_min_tahun'].toString()),
      limitMaksimal: double.parse(json['limit_maksimal'].toString()),
    );
  }
}

class DetailHP {
  final int id;
  final int pinjamanId;
  final String merkHp;
  final String modelHp;
  final double hargaHp;

  DetailHP({
    required this.id,
    required this.pinjamanId,
    required this.merkHp,
    required this.modelHp,
    required this.hargaHp,
  });

  factory DetailHP.fromJson(Map<String, dynamic> json) {
    return DetailHP(
      id: int.parse(json['id'].toString()),
      pinjamanId: int.parse(json['pinjaman_id'].toString()),
      merkHp: json['merk_hp'] ?? '',
      modelHp: json['model_hp'] ?? '',
      hargaHp: double.parse(json['harga_hp'].toString()),
    );
  }
}