import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SimpananRepository {
  static const String _key = 'simpanan_data';

  /// format:
  /// {
  ///   "anggota1": [
  ///      { "tanggal": "...", "jumlah": 50000 }
  ///   ]
  /// }
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

  static Future<void> tambahSimpanan(
    String username,
    int jumlah,
  ) async {
    data.putIfAbsent(username, () => []);
    data[username]!.add({
      'tanggal': DateTime.now().toIso8601String(),
      'jumlah': jumlah,
    });
    await save();
  }

  static int totalSimpanan(String username) {
    if (!data.containsKey(username)) return 0;
    return data[username]!
        .fold(0, (sum, item) => sum + (item['jumlah'] as int));
  }
}
