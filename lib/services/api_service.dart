import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost/koperasi_api';
  
  // Login user
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users.php?username=$username&password=$password'),
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
  
  // Get all users
  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users.php'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  // Add new user
  static Future<Map<String, dynamic>> addUser({
    required String username,
    required String nama,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'nama': nama,
          'password': password,
          'role': role,
        }),
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