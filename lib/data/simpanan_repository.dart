import '../models/simpanan_model.dart';
import '../services/simpanan_service.dart';

class SimpananRepository {
  static Future<bool> tambahSimpanan({
    required int userId,
    required double jumlah,
  }) async {
    return await SimpananService.addSimpanan(userId: userId, jumlah: jumlah);
  }

  /// Mengambil riwayat simpanan untuk seorang user.
  static Future<List<Simpanan>> getSimpananByUser(int userId) {
    return SimpananService.getSimpananByUser(userId);
  }

  /// Mengambil total saldo simpanan seorang user.
  static Future<double> getTotalSimpanan(int userId) {
    return SimpananService.getTotalSimpanan(userId);
  }

  /// Mengambil semua data simpanan (untuk admin).
  /// Asumsi: SimpananService akan memiliki metode ini.
  static Future<List<Simpanan>> getAllSimpanan() {
    // Anda perlu menambahkan implementasi di SimpananService untuk ini.
    return Future.value([]); // Placeholder
  }

  /// Load method for compatibility
  static Future<void> load() async {
    try {
      // Tidak perlu load karena data langsung dari MySQL
    } catch (e) {
      print('Error loading simpanan: $e');
    }
  }

  /// Compatibility method for old code
  static Future<int> totalSimpanan(String username) async {
    // This is a placeholder - need to get user ID first
    return 0;
  }
}
