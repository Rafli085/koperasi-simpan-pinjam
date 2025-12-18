import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/simpanan_model.dart';

class SimpananService {
  static const String baseUrl = 'http://localhost/koperasi_api';
  
  // Get simpanan by user
  static Future<List<Simpanan>> getSimpananByUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/simpanan.php?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Simpanan.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Add new simpanan
  static Future<bool> addSimpanan({
    required int userId,
    required double jumlah,
  }) async {
    try {
      print('DEBUG: Sending to $baseUrl/simpanan.php');
      print('DEBUG: userId=$userId, jumlah=$jumlah');
      
      final response = await http.post(
        Uri.parse('$baseUrl/simpanan.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'jumlah': jumlah,
        }),
      );
      
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['success'] == true;
      }
      return false;
    } catch (e) {
      print('DEBUG: Error in addSimpanan: $e');
      return false;
    }
  }
  
  // Get total simpanan by user
  static Future<double> getTotalSimpanan(int userId) async {
    try {
      final simpananList = await getSimpananByUser(userId);
      return simpananList.fold<double>(0.0, (sum, item) => sum + item.jumlah);
    } catch (e) {
      return 0.0;
    }
  }
}