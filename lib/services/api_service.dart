import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'settings_service.dart';

class ApiService {
  static Future<String> get baseUrl async {
    final ip = await SettingsService.getServerIp();
    return 'http://$ip/koperasi_api';
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/users.php'),
        body: {'action': 'login', 'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error during login: $e');
    }

    return {'success': false, 'message': 'Login gagal'};
  }

  static Future<List<dynamic>> getUsers() async {
    try {
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/users.php?action=list'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting users: $e');
    }

    return [];
  }

  static Future<Map<String, dynamic>> addUser({
    required String username,
    required String nama,
    required String password,
    required String role,
  }) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/users.php'),
        body: {
          'action': 'add',
          'username': username,
          'nama': nama,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error adding user: $e');
    }
    return {'success': false, 'message': 'Gagal menambahkan user'};
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
      },
    ];
  }

  static Future<Map<String, dynamic>> calculateLimit(
    int userId,
    int produkId,
  ) async {
    return {'success': true, 'limit_maksimal': 5000000};
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

  static List<Map<String, dynamic>> _offlineEvents = [];

  static Future<List<dynamic>> getEvents() async {
    try {
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/events.php?action=get_events'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        }
      }
    } catch (e) {
      print('Error getting events from server: $e');
    }

    return _offlineEvents;
  }

  static Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required String type,
    DateTime? endDate,
    List<String>? pollOptions,
  }) async {
    try {
      final body = {
        'action': 'create_event',
        'title': title,
        'description': description,
        'type': type,
        'poll_options': pollOptions,
      };

      if (endDate != null) {
        body['end_date'] = endDate.toIso8601String();
      }

      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/events.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error creating event on server: $e');
    }

    final newId = _offlineEvents.isEmpty
        ? 1
        : _offlineEvents
                  .map((e) => e['id'] as int)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    final newEvent = {
      'id': newId,
      'title': title,
      'description': description,
      'type': type,
      'created_at': DateTime.now().toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': true,
    };

    if (type == 'poll' && pollOptions != null) {
      newEvent['poll_options'] = pollOptions
          .asMap()
          .entries
          .map(
            (entry) => {'id': entry.key + 1, 'text': entry.value, 'votes': 0},
          )
          .toList();
      newEvent['user_votes'] = <int, int>{};
    }

    _offlineEvents.add(newEvent);
    return {'success': true, 'message': 'Event berhasil dibuat (offline)'};
  }

  static Future<Map<String, dynamic>> updateEvent({
    required int eventId,
    required String title,
    required String description,
    DateTime? endDate,
  }) async {
    try {
      final body = {
        'action': 'update_event',
        'event_id': eventId,
        'title': title,
        'description': description,
      };

      if (endDate != null) {
        body['end_date'] = endDate.toIso8601String();
      }

      final url = await baseUrl;
      final response = await http.put(
        Uri.parse('$url/events.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error updating event on server: $e');
    }

    final eventIndex = _offlineEvents.indexWhere((e) => e['id'] == eventId);
    if (eventIndex == -1) {
      return {'success': false, 'message': 'Event tidak ditemukan'};
    }

    _offlineEvents[eventIndex]['title'] = title;
    _offlineEvents[eventIndex]['description'] = description;
    _offlineEvents[eventIndex]['end_date'] = endDate?.toIso8601String();

    return {'success': true, 'message': 'Event berhasil diupdate (offline)'};
  }

  static Future<Map<String, dynamic>> deleteEvent(int eventId) async {
    try {
      final url = await baseUrl;
      final response = await http.delete(
        Uri.parse('$url/events.php?action=delete_event&id=$eventId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error deleting event on server: $e');
    }

    final eventIndex = _offlineEvents.indexWhere((e) => e['id'] == eventId);
    if (eventIndex == -1) {
      return {'success': false, 'message': 'Event tidak ditemukan'};
    }

    _offlineEvents.removeAt(eventIndex);
    return {'success': true, 'message': 'Event berhasil dihapus (offline)'};
  }

  static Future<Map<String, dynamic>> voteOnPoll(
    int eventId,
    int userId,
    int optionId,
  ) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/events.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'vote_poll',
          'event_id': eventId,
          'user_id': userId,
          'option_id': optionId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error voting on server: $e');
    }

    final eventIndex = _offlineEvents.indexWhere((e) => e['id'] == eventId);
    if (eventIndex == -1) {
      return {'success': false, 'message': 'Event tidak ditemukan'};
    }

    final event = _offlineEvents[eventIndex];
    if (event['type'] != 'poll') {
      return {'success': false, 'message': 'Event bukan polling'};
    }

    final pollOptions = event['poll_options'] as List;
    final optionIndex = pollOptions.indexWhere((opt) => opt['id'] == optionId);
    if (optionIndex == -1) {
      return {'success': false, 'message': 'Opsi tidak ditemukan'};
    }

    final userVotes = event['user_votes'] as Map<int, int>;
    if (userVotes.containsKey(userId)) {
      final prevOptionId = userVotes[userId]!;
      final prevOptionIndex = pollOptions.indexWhere(
        (opt) => opt['id'] == prevOptionId,
      );
      if (prevOptionIndex != -1) {
        pollOptions[prevOptionIndex]['votes']--;
      }
    }

    pollOptions[optionIndex]['votes']++;
    userVotes[userId] = optionId;

    return {'success': true, 'message': 'Vote berhasil (offline)'};
  }
}