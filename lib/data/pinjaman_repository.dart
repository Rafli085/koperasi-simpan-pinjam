import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PinjamanRepository {
  static const String _key = 'pinjaman_data';

  /// STRUKTUR DATA
  /// {
  ///   aktif: {
  ///     username: [ { pinjaman }, ... ]
  ///   },
  ///   riwayat: {
  ///     username: [ { pinjaman }, ... ]
  ///   }
  /// }
  static Map<String, Map<String, List<Map<String, dynamic>>>> data = {
    'aktif': {},
    'riwayat': {},
  };

  // ===============================
  // LOAD & SAVE
  // ===============================

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return;

    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    data = {
      'aktif': {},
      'riwayat': {},
    };

    for (final status in ['aktif', 'riwayat']) {
      if (decoded[status] is Map) {
        (decoded[status] as Map).forEach((username, list) {
          data[status]![username] =
              List<Map<String, dynamic>>.from(list);
        });
      }
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  // ===============================
  // TAMBAH PINJAMAN (MENUNGGU)
  // ===============================

  static Future<void> tambahPinjaman({
    required String username,
    required int jumlah,
    required int tenor,
  }) async {
    data['aktif']!.putIfAbsent(username, () => []);

    data['aktif']![username]!.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'jumlah': jumlah,
      'tenor': tenor,
      'tanggalPengajuan': DateTime.now().toIso8601String(),
      'tanggalMulai': null,
      'tanggalLunas': null,
      'status': 'menunggu',
      'cicilan': <Map<String, dynamic>>[],
    });

    await save();
  }

  // ===============================
  // APPROVE PINJAMAN (KETUA)
  // ===============================

  static Future<void> approvePinjaman({
    required String username,
    required String pinjamanId,
  }) async {
    final list = data['aktif']![username];
    if (list == null) return;

    final pinjaman = list.firstWhere(
      (p) => p['id'] == pinjamanId,
      orElse: () => {},
    );

    if (pinjaman.isEmpty) return;

    pinjaman['status'] = 'aktif';
    pinjaman['tanggalMulai'] = DateTime.now().toIso8601String();

    await save();
  }

  // ===============================
  // TAMBAH CICILAN
  // ===============================

  static Future<void> tambahCicilan({
    required String username,
    required String pinjamanId,
    required int jumlah,
  }) async {
    final list = data['aktif']![username];
    if (list == null) return;

    final pinjaman = list.firstWhere(
      (p) => p['id'] == pinjamanId,
      orElse: () => {},
    );

    if (pinjaman.isEmpty || pinjaman['status'] != 'aktif') return;

    (pinjaman['cicilan'] as List).add({
      'tanggal': DateTime.now().toIso8601String(),
      'jumlah': jumlah,
    });

    final totalBayar = (pinjaman['cicilan'] as List)
        .fold<int>(0, (s, c) => s + (c['jumlah'] as int));

    if (totalBayar >= pinjaman['jumlah']) {
      _pindahKeRiwayat(username, pinjaman);
    }

    await save();
  }

  // ===============================
  // PINDAH KE RIWAYAT (LUNAS)
  // ===============================

  static void _pindahKeRiwayat(
    String username,
    Map<String, dynamic> pinjaman,
  ) {
    data['aktif']![username]!
        .removeWhere((p) => p['id'] == pinjaman['id']);

    data['riwayat']!.putIfAbsent(username, () => []);

    pinjaman['status'] = 'lunas';
    pinjaman['tanggalLunas'] = DateTime.now().toIso8601String();

    data['riwayat']![username]!.add(pinjaman);
  }

  // ===============================
  // HELPER
  // ===============================

  static int sisaPinjaman(Map<String, dynamic> pinjaman) {
    final total = (pinjaman['cicilan'] as List)
        .fold<int>(0, (s, c) => s + (c['jumlah'] as int));
    return pinjaman['jumlah'] - total;
  }

  static List<Map<String, dynamic>> semuaRiwayat() {
    final List<Map<String, dynamic>> result = [];

    data['riwayat']!.forEach((username, list) {
      for (var p in list) {
        result.add({
          ...p,
          'username': username,
        });
      }
    });

    return result;
  }
}
