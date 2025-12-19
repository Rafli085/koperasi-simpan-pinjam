import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // URL untuk web (Chrome)
  static const String webBaseUrl = 'http://localhost/koperasi_api';
  // URL untuk mobile
  static const String mobileBaseUrl = 'http://192.168.188.74/koperasi_api';
  
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
      String username, String password) async {
    try {
      print('Trying to connect to: $baseUrl/users.php');
      final response = await http.post(
        Uri.parse('$baseUrl/users.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
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
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
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
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
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
}
