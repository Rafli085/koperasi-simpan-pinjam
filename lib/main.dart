import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme/app_theme.dart';

import 'data/dummy_users.dart';
import 'data/simpanan_repository.dart';
import 'data/pinjaman_repository.dart';

import 'pages/login_page.dart';
import 'pages/dashboard_anggota_sederhana.dart';
import 'pages/dashboard_admin.dart';

void main() {
  runApp(const MyApp());
}

///
/// ALIAS ROOT APP
/// MyApp dipakai untuk standard Flutter & widget test
///
class MyApp extends KoperasiApp {
  const MyApp({super.key});
}

///
/// ROOT APLIKASI SEBENARNYA
///
class KoperasiApp extends StatefulWidget {
  const KoperasiApp({super.key});

  @override
  State<KoperasiApp> createState() => _KoperasiAppState();
}

class _KoperasiAppState extends State<KoperasiApp> {
  ThemeMode _themeMode = ThemeMode.light;

  String? _username;
  String? _role; // anggota | admin_keuangan | ketua
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _role = prefs.getString('role');
      _userId = prefs.getInt('userId');
      _themeMode =
          (prefs.getBool('darkTheme') ?? false) ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // ======================
  // SESSION & PREFERENCES
  // ======================

  Future<void> login(String username, String role, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('role', role);
    await prefs.setInt('userId', userId);

    setState(() {
      _username = username;
      _role = role;
      _userId = userId;
    });
  }



  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', mode == ThemeMode.dark);

    setState(() {
      _themeMode = mode;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('role');
    await prefs.remove('userId');

    setState(() {
      _username = null;
      _role = null;
      _userId = null;
    });
  }

  // ======================
  // ROUTING LOGIC
  // ======================

  Widget _buildHome() {
    // BELUM LOGIN
    if (_username == null || _role == null) {
      return LoginPage(onLogin: login);
    }

    // ROLE: ANGGOTA
    if (_role == 'anggota') {
      return DashboardAnggotaSederhana(
        username: _username!,
        userId: _userId ?? 1,
        onLogout: logout,
      );
    }

    // ROLE: ADMIN / KETUA
    return DashboardAdmin(
      role: _role!,
      username: _username!,
      onLogout: logout,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPM Koperasi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: _buildHome(),
    );
  }
}
