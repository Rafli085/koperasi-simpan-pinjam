import '../services/user_service.dart';
import '../models/user_model.dart';

class DummyUsers {
  static List<User> users = [];

  /// WAJIB dipanggil saat app start
  static Future<void> load() async {
    // Load users dari MySQL API
    users = await UserService.getAllUsers();
  }

  /// Login user
  static Future<User?> login(String username, String password) async {
    return await UserService.login(username, password);
  }

  /// Tambah anggota baru
  static Future<bool> tambahAnggota({
    required String nama,
    required String username,
    required String password,
  }) async {
    final success = await UserService.addUser(
      username: username,
      nama: nama,
      password: password,
      role: 'anggota',
    );
    
    if (success) {
      // Refresh data setelah tambah user
      await load();
    }
    
    return success;
  }

  /// Get user by username from the API
  static User? getUserByUsername(String username) {
    // Search from the loaded list of users
    try {
      return users.firstWhere((user) => user.username == username);
    } catch (e) {
      return null;
    }
  }

  /// Get all anggota
  static List<User> getAllAnggota() {
    return users.where((user) => user.role == 'anggota').toList();
  }

  /// Hapus anggota
  static Future<bool> deleteAnggota(int userId) async {
    final success = await UserService.deleteUser(userId);
    if (success) {
      // Refresh data setelah hapus user
      await load();
    }
    return success;
  }

  /// Save method (untuk kompatibilitas)
  static Future<void> save() async {
    // Tidak perlu save karena langsung ke database
  }
}
