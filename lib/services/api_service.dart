import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // URL untuk web (Chrome)
  static const String webBaseUrl = 'http://localhost/koperasi_api';
  // URL untuk mobile
  static const String mobileBaseUrl = 'http://10.249.214.57/koperasi_api';

  // Pilih base URL berdasarkan platform
  static String get baseUrl {
    if (kIsWeb) {
      return webBaseUrl;
    } else {
      return mobileBaseUrl;
    }
  }

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      print('Trying to connect to: $baseUrl/users.php');
      final response = await http.post(
        Uri.parse('$baseUrl/users.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'action': 'login',
          'username': username.trim(),
          'password': password.trim(),
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ================= GET USERS =================
  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users.php?action=list'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // ================= ADD USER =================
  static Future<Map<String, dynamic>> addUser({
    required String username,
    required String nama,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'action': 'add',
          'username': username.trim(),
          'nama': nama.trim(),
          'password': password.trim(),
          'role': role.trim(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ================= PRODUK KOPERASI =================
  static Future<List<dynamic>> getProduk() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produk.php?action=get_produk'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> calculateLimit(int userId, int produkId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/produk.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'action': 'calculate_limit',
          'user_id': userId.toString(),
          'produk_id': produkId.toString(),
        },
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getTotalPinjamanAktif(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produk.php?action=get_total_pinjaman_aktif&user_id=$userId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ================= PENGAJUAN PINJAMAN =================
  static Future<Map<String, dynamic>> ajukanPinjaman({
    required int userId,
    required int produkId,
    required double jumlah,
    required int tenor,
    required String keperluan,
    String? merkHp,
    String? modelHp,
    double? hargaHp,
  }) async {
    try {
      final body = {
        'action': 'ajukan',
        'user_id': userId.toString(),
        'produk_id': produkId.toString(),
        'jumlah': jumlah.toString(),
        'tenor': tenor.toString(),
        'keperluan': keperluan,
      };
      
      if (merkHp != null) body['merk_hp'] = merkHp;
      if (modelHp != null) body['model_hp'] = modelHp;
      if (hargaHp != null) body['harga_hp'] = hargaHp.toString();
      
      final response = await http.post(
        Uri.parse('$baseUrl/pengajuan.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<List<dynamic>> getPengajuan(String role, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pengajuan.php?action=list_pengajuan&role=$role&user_id=$userId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> prosesAdmin({
    required int pengajuanId,
    required int adminId,
    required String action,
    required String catatan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pengajuan.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'action': 'proses_admin',
          'pengajuan_id': pengajuanId.toString(),
          'admin_id': adminId.toString(),
          'admin_action': action,
          'catatan': catatan,
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> approvalKetua({
    required int pengajuanId,
    required int ketuaId,
    required String action,
    required String catatan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pengajuan.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'action': 'approval_ketua',
          'pengajuan_id': pengajuanId.toString(),
          'ketua_id': ketuaId.toString(),
          'ketua_action': action,
          'catatan': catatan,
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // ================= STATUS PINJAMAN =================
  static Future<Map<String, dynamic>> getStatusPinjaman(int pinjamanId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status_pinjaman.php?action=get_status_pinjaman&pinjaman_id=$pinjamanId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateStatusLunas() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/status_pinjaman.php'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'action': 'update_status_lunas'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Server error'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  static Future<List<dynamic>> getDetailPinjaman(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status_pinjaman.php?action=get_detail_pinjaman&user_id=$userId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
