import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PinjamanRepository {
  static const String _key = 'pinjaman_data';

  static Map<String, List<Map<String, dynamic>>> data = {};

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) {
      data = {};
      await save();
    } else {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      data = decoded.map(
        (key, value) => MapEntry(
          key,
          List<Map<String, dynamic>>.from(value),
        ),
      );
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(data));
  }

  static Future<void> tambahPinjaman({
    required String username,
    required int jumlah,
    required int tenor,
  }) async {
    data.putIfAbsent(username, () => []);
    data[username]!.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'tanggal': DateTime.now().toIso8601String(),
      'jumlah': jumlah,
      'tenor': tenor,
      'status': 'menunggu', // 🔥 DEFAULT
      'cicilan': <Map<String, dynamic>>[],
    });
    await save();
  }

  static Future<void> setStatus({
    required String username,
    required String pinjamanId,
    required String status,
  }) async {
    final pinjaman =
        data[username]!.firstWhere((p) => p['id'] == pinjamanId);
    pinjaman['status'] = status;
    await save();
  }

  static Future<void> tambahCicilan({
    required String username,
    required String pinjamanId,
    required int jumlah,
  }) async {
    final pinjaman =
        data[username]!.firstWhere((p) => p['id'] == pinjamanId);

    if (pinjaman['status'] != 'aktif') return;

    pinjaman['cicilan'].add({
      'tanggal': DateTime.now().toIso8601String(),
      'jumlah': jumlah,
    });

    final total = (pinjaman['cicilan'] as List)
        .fold<int>(0, (s, c) => s + (c['jumlah'] as int));

    if (total >= pinjaman['jumlah']) {
      pinjaman['status'] = 'lunas';
    }

    await save();
  }

  static int sisaPinjaman(Map<String, dynamic> pinjaman) {
    final total = (pinjaman['cicilan'] as List)
        .fold<int>(0, (s, c) => s + (c['jumlah'] as int));
    return pinjaman['jumlah'] - total;
  }
}
