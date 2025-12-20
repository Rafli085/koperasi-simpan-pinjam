class ProdukKoperasi {
  final int id;
  final String namaProduk;
  final String jenis;
  final double bungaPersen;
  final String bungaPer;
  final int? tenorMin;
  final int? tenorMax;
  final double? limitMin;
  final double? limitMax;

  ProdukKoperasi({
    required this.id,
    required this.namaProduk,
    required this.jenis,
    required this.bungaPersen,
    required this.bungaPer,
    this.tenorMin,
    this.tenorMax,
    this.limitMin,
    this.limitMax,
  });

  factory ProdukKoperasi.fromJson(Map<String, dynamic> json) {
    return ProdukKoperasi(
      id: json['id'] ?? 0,
      namaProduk: json['nama_produk'] ?? '',
      jenis: json['jenis'] ?? '',
      bungaPersen: (json['bunga_persen'] ?? 0).toDouble(),
      bungaPer: json['bunga_per'] ?? '',
      tenorMin: json['tenor_min'],
      tenorMax: json['tenor_max'],
      limitMin: json['limit_min']?.toDouble(),
      limitMax: json['limit_max']?.toDouble(),
    );
  }
}