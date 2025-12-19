import '../models/pinjaman_model.dart';
import '../services/pinjaman_service.dart';

class PinjamanRepository {
  static Future<void> tambahPinjaman({
    required int userId,
    required double jumlah,
    required int tenor,
  }) async {
    await PinjamanService.addPinjaman(
      userId: userId,
      jumlah: jumlah,
      tenor: tenor,
    );
  }

  static Future<void> setStatus({
    required int pinjamanId,
    required String status,
  }) async {
    await PinjamanService.updateStatus(pinjamanId: pinjamanId, status: status);
  }

  /// Mengambil semua data pinjaman untuk seorang user.
  static Future<List<Pinjaman>> getPinjamanByUser(int userId) {
    return PinjamanService.getPinjamanByUser(userId);
  }

  /// Mengambil semua data pinjaman (untuk admin).
  /// Asumsi: PinjamanService akan memiliki metode ini.
  static Future<List<Pinjaman>> getAllPinjaman() async {
    return await PinjamanService.getAllPinjaman();
  }

  /// Menambah pembayaran cicilan.
  /// Asumsi: PinjamanService akan memiliki metode ini.
  static Future<bool> tambahCicilan({
    required int pinjamanId,
    required double jumlah,
  }) async {
    return await PinjamanService.addCicilan(pinjamanId: pinjamanId, jumlah: jumlah);
  }

  /// Load method for compatibility
  static Future<void> load() async {
    try {
      // Tidak perlu load karena data langsung dari MySQL
    } catch (e) {
      print('Error loading pinjaman: $e');
    }
  }

  /// Calculate sisa pinjaman
  static double sisaPinjaman(Map<String, dynamic> pinjaman) {
    final total = (pinjaman['cicilan'] as List? ?? [])
        .fold<double>(0.0, (s, c) => s + ((c['jumlah'] as num?)?.toDouble() ?? 0.0));
    return ((pinjaman['jumlah'] as num?)?.toDouble() ?? 0.0) - total;
  }
}
