class NotifikasiService {
  static List<Map<String, dynamic>> _pengajuanBaru = [];

  // Tambah pengajuan baru ke notifikasi
  static void tambahPengajuan(Map<String, dynamic> pengajuan) {
    _pengajuanBaru.add({
      ...pengajuan,
      'id': DateTime.now().millisecondsSinceEpoch,
      'tanggal_pengajuan': DateTime.now().toIso8601String(),
      'status': 'pending',
      'dibaca': false, // Status baca
    });
  }

  // Get semua pengajuan
  static List<Map<String, dynamic>> getPengajuanBaru() {
    return List.from(_pengajuanBaru);
  }

  // Tandai sebagai sudah dibaca
  static void tandaiDibaca(int id) {
    final index = _pengajuanBaru.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      _pengajuanBaru[index]['dibaca'] = true;
    }
  }

  // Tandai sebagai belum dibaca
  static void tandaiBelumDibaca(int id) {
    final index = _pengajuanBaru.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      _pengajuanBaru[index]['dibaca'] = false;
    }
  }

  // Get jumlah pengajuan belum dibaca
  static int getJumlahBelumDibaca() {
    return _pengajuanBaru.where((p) => p['dibaca'] == false).length;
  }

  // Hapus pengajuan
  static void hapusPengajuan(int id) {
    _pengajuanBaru.removeWhere((p) => p['id'] == id);
  }

  // Clear semua notifikasi
  static void clearAll() {
    _pengajuanBaru.clear();
  }
}