import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  static const String webBaseUrl = 'http://localhost';
  static const String mobileBaseUrl = 'http://10.242.171.71';

  static String get baseUrl {
    return kIsWeb ? webBaseUrl : mobileBaseUrl;
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    // LOGIN OFFLINE UNTUK TESTING
    final testUsers = {
      'anggota1': {'password': '123456', 'role': 'anggota', 'nama': 'Budi Santoso'},
      'admin': {'password': 'admin123', 'role': 'admin_keuangan', 'nama': 'Admin Keuangan'},
      'ketua': {'password': 'ketua123', 'role': 'ketua', 'nama': 'Ketua Koperasi'},
      'Mario': {'password': '123123', 'role': 'anggota', 'nama': 'Mario'},
    };

    final user = testUsers[username];
    if (user != null && user['password'] == password) {
      return {
        'success': true,
        'user': {
          'id': 1,
          'username': username,
          'nama': user['nama'],
          'role': user['role'],
        }
      };
    }

    return {'success': false, 'message': 'Username atau password salah'};
  }

  static Future<List<dynamic>> getUsers() async {
    return [
      {'id': 1, 'username': 'anggota1', 'nama': 'Budi Santoso', 'role': 'anggota'},
      {'id': 2, 'username': 'admin', 'nama': 'Admin Keuangan', 'role': 'admin_keuangan'},
      {'id': 3, 'username': 'ketua', 'nama': 'Ketua Koperasi', 'role': 'ketua'},
      {'id': 4, 'username': 'Mario', 'nama': 'Mario', 'role': 'anggota'},
    ];
  }

  static Future<Map<String, dynamic>> addUser({
    required String username,
    required String nama,
    required String password,
    required String role,
  }) async {
    return {'success': true, 'message': 'User berhasil ditambahkan (offline mode)'};
  }

  static Future<List<dynamic>> getPengajuan(String type, int userId) async {
    return [];
  }

  static Future<List<dynamic>> getDetailPinjaman(int userId) async {
    return [];
  }

  static Future<List<dynamic>> getProduk() async {
    return [
      {
        'id': 1,
        'nama_produk': 'Pinjaman Reguler',
        'jenis': 'reguler',
        'bunga_persen': 2.5,
        'bunga_per': 'bulan',
        'tenor_min': 1,
        'tenor_max': 12,
      }
    ];
  }

  static Future<Map<String, dynamic>> calculateLimit(int userId, int produkId) async {
    return {
      'success': true,
      'limit_maksimal': 5000000,
    };
  }

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
    return {
      'success': true,
      'message': 'Pengajuan pinjaman berhasil disubmit (offline mode)',
    };
  }
}