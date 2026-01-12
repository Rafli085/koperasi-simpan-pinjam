import '../services/api_service.dart';

class RiwayatPinjamanService {
  static List<Map<String, dynamic>> _riwayatPinjaman = [];

  // Tambah pinjaman ke riwayat (dari pengajuan yang disetujui)
  static void tambahRiwayat(Map<String, dynamic> pinjaman) {
    _riwayatPinjaman.add({
      ...pinjaman,
      'id': DateTime.now().millisecondsSinceEpoch,
      'tanggal_pinjaman': DateTime.now().toIso8601String(),
      'status_pinjaman': 'aktif',
    });
  }

  // Get riwayat pinjaman berdasarkan user ID dari database
  static Future<List<Map<String, dynamic>>> getRiwayatByUserId(int userId) async {
    final data = await ApiService.getPinjaman(userId: userId);
    return data.cast<Map<String, dynamic>>();
  }

  // Get riwayat pinjaman berdasarkan username (fallback untuk data lokal)
  static List<Map<String, dynamic>> getRiwayatByUsername(String username) {
    return _riwayatPinjaman.where((p) => p['username'] == username).toList();
  }

  // Get semua riwayat pinjaman dari database
  static Future<List<Map<String, dynamic>>> getAllRiwayat() async {
    final data = await ApiService.getPinjaman();
    return data.cast<Map<String, dynamic>>();
  }

  // Update status pinjaman (untuk data lokal)
  static void updateStatus(int id, String status) {
    final index = _riwayatPinjaman.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      _riwayatPinjaman[index]['status_pinjaman'] = status;
    }
  }

  // Hapus riwayat
  static void hapusRiwayat(int id) {
    _riwayatPinjaman.removeWhere((p) => p['id'] == id);
  }

  // Clear semua riwayat
  static void clearAll() {
    _riwayatPinjaman.clear();
  }
}