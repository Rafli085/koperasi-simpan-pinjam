import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pinjaman_model.dart';
import 'api_service.dart';

class PinjamanService {
  // Get pinjaman by user
  static Future<List<Pinjaman>> getPinjamanByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/pinjaman.php?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Pinjaman.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Add new pinjaman
  static Future<bool> addPinjaman({
    required int userId,
    required double jumlah,
    required int tenor,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/pinjaman.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'jumlah': jumlah,
          'tenor': tenor,
        }),
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Update pinjaman status
  static Future<bool> updateStatus({
    required int pinjamanId,
    required String status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/pinjaman.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': pinjamanId,
          'status': status,
        }),
      );
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get all pinjaman (for admin)
  static Future<List<Pinjaman>> getAllPinjaman() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/pinjaman.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Pinjaman.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Add new cicilan
  static Future<bool> addCicilan({
    required int pinjamanId,
    required double jumlah,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/cicilan.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'pinjaman_id': pinjamanId,
          'jumlah': jumlah,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}