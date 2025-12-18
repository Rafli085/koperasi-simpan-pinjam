class Simpanan {
  final int? id;
  final int userId;
  final double jumlah;
  final DateTime tanggal;

  Simpanan({
    this.id,
    required this.userId,
    required this.jumlah,
    required this.tanggal,
  });

  factory Simpanan.fromJson(Map<String, dynamic> json) {
    return Simpanan(
      id: json['id'],
      userId: json['user_id'],
      jumlah: double.parse(json['jumlah'].toString()),
      tanggal: DateTime.parse(json['tanggal']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'jumlah': jumlah,
      'tanggal': tanggal.toIso8601String(),
    };
  }
}