class Pinjaman {
  final int? id;
  final int userId;
  final double jumlah;
  final int tenor;
  final String status; // menunggu, aktif, lunas, ditolak
  final DateTime tanggal;

  // ⬇️ TAMBAHAN (AMAN)
  final DateTime? tanggalApproval;

  final List<Cicilan> cicilan;

  Pinjaman({
    this.id,
    required this.userId,
    required this.jumlah,
    required this.tenor,
    required this.status,
    required this.tanggal,
    this.tanggalApproval, // ⬅️ BARU
    this.cicilan = const [],
  });

  factory Pinjaman.fromJson(Map<String, dynamic> json) {
    return Pinjaman(
      id: json['id'],
      userId: json['user_id'],
      jumlah: double.parse(json['jumlah'].toString()),
      tenor: json['tenor'],
      status: json['status'],
      tanggal: DateTime.parse(json['tanggal']),

      // ⬇️ AMAN KARENA NULLABLE
      tanggalApproval: json['tanggal_approval'] != null
          ? DateTime.parse(json['tanggal_approval'])
          : null,

      cicilan: json['cicilan'] != null
          ? (json['cicilan'] as List)
              .map((c) => Cicilan.fromJson(c))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'jumlah': jumlah,
      'tenor': tenor,
      'status': status,
      'tanggal': tanggal.toIso8601String(),

      // ⬇️ TIDAK WAJIB DIKIRIM, TAPI AMAN
      'tanggal_approval': tanggalApproval?.toIso8601String(),

      'cicilan': cicilan.map((c) => c.toJson()).toList(),
    };
  }

  double get sisaPinjaman {
    final totalCicilan = cicilan.fold<double>(0, (sum, c) => sum + c.jumlah);
    return jumlah - totalCicilan;
  }
}

class Cicilan {
  final int? id;
  final int pinjamanId;
  final double jumlah;
  final DateTime tanggal;

  Cicilan({
    this.id,
    required this.pinjamanId,
    required this.jumlah,
    required this.tanggal,
  });

  factory Cicilan.fromJson(Map<String, dynamic> json) {
    return Cicilan(
      id: json['id'],
      pinjamanId: json['pinjaman_id'],
      jumlah: double.parse(json['jumlah'].toString()),
      tanggal: DateTime.parse(json['tanggal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pinjaman_id': pinjamanId,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
    };
  }
}
