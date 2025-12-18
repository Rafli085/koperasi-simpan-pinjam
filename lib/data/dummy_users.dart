import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DummyUsers {
  static Map<String, Map<String, String>> users = {};

  static const String _storageKey = 'dummy_users';

  // DEFAULT DATA (PERTAMA KALI APP DIJALANKAN)
  static final Map<String, Map<String, String>> _defaultUsers = {
    'anggota1': {
      'nama': 'Budi Santoso',
      'password': '123456',
      'role': 'anggota',
    },
    'admin': {
      'nama': 'Admin Keuangan',
      'password': 'admin123',
      'role': 'admin_keuangan',
    },
    'ketua': {
      'nama': 'Ketua Koperasi',
      'password': 'ketua123',
      'role': 'ketua',
    },
  };

  /// WAJIB dipanggil saat app start
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      // pertama kali → isi default
      users = Map.from(_defaultUsers);
      await save();
    } else {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      users = decoded.map(
        (key, value) => MapEntry(
          key,
          Map<String, String>.from(value),
        ),
      );
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(users);
    await prefs.setString(_storageKey, jsonString);
  }

  static Future<void> tambahAnggota({
    required String nama,
    required String username,
    required String password,
  }) async {
    users[username] = {
      'nama': nama,
      'password': password,
      'role': 'anggota',
    };
    await save();
  }
}
