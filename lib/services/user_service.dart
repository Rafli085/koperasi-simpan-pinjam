import '../models/user_model.dart';
import 'api_service.dart';

class UserService {
  // Login user
  static Future<User?> login(String username, String password) async {
    final result = await ApiService.login(username, password);
    
    if (result['success'] == true && result['user'] != null) {
      return User.fromJson(result['user']);
    }
    return null;
  }
  
  // Get all users
  static Future<List<User>> getAllUsers() async {
    final usersData = await ApiService.getUsers();
    return usersData.map((userData) => User.fromJson(userData)).toList();
  }
  
  // Add new user
  static Future<bool> addUser({
    required String username,
    required String nama,
    required String password,
    required String role,
  }) async {
    final result = await ApiService.addUser(
      username: username,
      nama: nama,
      password: password,
      role: role,
    );
    
    return result['success'] == true;
  }

  // Delete user (placeholder)
  static Future<bool> deleteUser(int userId) async {
    // TODO: Implement delete user API
    return false;
  }
}