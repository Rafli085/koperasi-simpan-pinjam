import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _serverIpKey = 'server_ip';
  static const String _defaultWebIp = '192.168.188.74';
  static const String _defaultMobileIp = '10.242.171.71';

  static Future<String> getServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_serverIpKey) ?? _defaultWebIp;
  }

  static Future<void> setServerIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_serverIpKey, ip);
  }

  static Future<void> resetServerIp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverIpKey);
  }
}