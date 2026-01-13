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
      final response = await http.get(Uri.parse('$url/users.php?action=list'));

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

  static Future<Map<String, dynamic>> editUser(
    int userId,
    String username,
    String nama,
  ) async {
    try {
      final url = await baseUrl;
      final response = await http.put(
        Uri.parse('$url/users.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'edit',
          'id': userId,
          'username': username,
          'nama': nama,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error editing user: $e');
    }
    return {'success': false, 'message': 'Gagal mengedit user'};
  }

  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final url = await baseUrl;
      final response = await http.delete(
        Uri.parse('$url/users.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'delete',
          'id': userId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error deleting user: $e');
    }
    return {'success': false, 'message': 'Gagal menghapus user'};
  }

  static Future<List<dynamic>> getPengajuan(String type, int userId) async {
    try {
      final url = await baseUrl;
      final response = await http.get(
        Uri.parse('$url/pengajuan.php?action=list&type=$type&user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting pengajuan: $e');
    }
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
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/pengajuan.php'),
        body: {
          'action': 'ajukan',
          'user_id': userId.toString(),
          'produk_id': produkId.toString(),
          'jumlah': jumlah.toString(),
          'tenor': tenor.toString(),
          'keperluan': keperluan,
          'merk_hp': merkHp ?? '',
          'model_hp': modelHp ?? '',
          'harga_hp': hargaHp?.toString() ?? '0',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error submitting pengajuan: $e');
    }

    return {'success': false, 'message': 'Gagal mengajukan pinjaman'};
  }

  // Method untuk notifikasi admin
  static Future<List<dynamic>> getPengajuanBaru({String? role}) async {
    try {
      final url = await baseUrl;
      String endpoint = '$url/pengajuan.php?action=list_baru';
      if (role != null) {
        endpoint += '&role=$role';
      }

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting pengajuan baru: $e');
    }
    return [];
  }

  // Method untuk memproses pengajuan ke pinjaman
  static Future<Map<String, dynamic>> prosesKePinjaman(int pengajuanId) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/pengajuan.php'),
        body: {
          'action': 'proses_ke_pinjaman',
          'pengajuan_id': pengajuanId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error processing pengajuan: $e');
    }
    return {'success': false, 'message': 'Gagal memproses pengajuan'};
  }

  // Method untuk admin memproses pengajuan ke ketua
  static Future<Map<String, dynamic>> prosesAdmin(int pengajuanId) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/pengajuan.php'),
        body: {
          'action': 'proses_admin',
          'pengajuan_id': pengajuanId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error processing admin: $e');
    }
    return {'success': false, 'message': 'Gagal memproses pengajuan'};
  }

  // Method untuk ketua menyetujui/menolak pengajuan
  static Future<Map<String, dynamic>> approveKetua(
    int pengajuanId,
    String status,
  ) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/pengajuan.php'),
        body: {
          'action': 'approve_ketua',
          'pengajuan_id': pengajuanId.toString(),
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error approving ketua: $e');
    }
    return {'success': false, 'message': 'Gagal memproses pengajuan'};
  }

  // Method untuk menghapus pengajuan
  static Future<Map<String, dynamic>> hapusPengajuan(int pengajuanId) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/pengajuan.php'),
        body: {'action': 'hapus', 'pengajuan_id': pengajuanId.toString()},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error deleting pengajuan: $e');
    }
    return {'success': false, 'message': 'Gagal menghapus pengajuan'};
  }

  // Method untuk mengambil data pinjaman
  static Future<Map<String, dynamic>> getPinjaman({int? userId}) async {
    try {
      final url = await baseUrl;
      String endpoint = '$url/pinjaman.php';
      if (userId != null) {
        endpoint += '?user_id=$userId';
      }

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      }
    } catch (e) {
      print('Error getting pinjaman: $e');
    }
    return {'success': false, 'data': []};
  }

  // Method untuk bayar cicilan
  static Future<Map<String, dynamic>> bayarCicilan(
    int pinjamanId,
    int jumlahBayar,
  ) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/cicilan.php'),
        body: {
          'action': 'bayar',
          'pinjaman_id': pinjamanId.toString(),
          'jumlah_bayar': jumlahBayar.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error bayar cicilan: $e');
    }
    return {'success': false, 'message': 'Gagal bayar cicilan'};
  }

  // Method untuk bayar cicilan dengan tanggal
  static Future<Map<String, dynamic>> bayarCicilanWithDate(
    int pinjamanId,
    int jumlahBayar,
    DateTime tanggal,
  ) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/cicilan.php'),
        body: {
          'action': 'bayar',
          'pinjaman_id': pinjamanId.toString(),
          'jumlah_bayar': jumlahBayar.toString(),
          'tanggal': tanggal.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error bayar cicilan: $e');
    }
    return {'success': false, 'message': 'Gagal bayar cicilan'};
  }

  // Method untuk get history cicilan
  static Future<List<dynamic>> getHistoryCicilan({int? userId}) async {
    try {
      final url = await baseUrl;
      String endpoint = '$url/cicilan.php?action=history';
      if (userId != null) {
        endpoint += '&user_id=$userId';
      }

      final response = await http.get(Uri.parse(endpoint));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting history cicilan: $e');
    }
    return [];
  }

  // Method untuk menambah cicilan
  static Future<Map<String, dynamic>> tambahCicilan(
    int pinjamanId,
    double jumlah,
  ) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/cicilan.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'pinjaman_id': pinjamanId, 'jumlah': jumlah}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error adding cicilan: $e');
    }
    return {'success': false, 'message': 'Gagal menambah cicilan'};
  }

  // Method untuk menghapus pinjaman
  static Future<Map<String, dynamic>> hapusPinjaman(int pinjamanId) async {
    try {
      final url = await baseUrl;
      final response = await http.delete(
        Uri.parse('$url/pinjaman.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': pinjamanId}),
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final result = json.decode(response.body);
          return {
            'success': result['success'] ?? false,
            'message': result['message'] ?? 'Response tidak valid',
          };
        } catch (e) {
          print('JSON decode error: $e');
          return {
            'success': false,
            'message': 'Server mengembalikan response yang tidak valid: ${response.body}',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error deleting pinjaman: $e');
      return {'success': false, 'message': 'Gagal menghapus pinjaman: $e'};
    }
  }

  // Method untuk edit pinjaman
  static Future<Map<String, dynamic>> editPinjaman(
    int pinjamanId,
    double jumlah,
    int tenor,
  ) async {
    try {
      final url = await baseUrl;
      final response = await http.put(
        Uri.parse('$url/pinjaman.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'edit',
          'id': pinjamanId,
          'jumlah': jumlah,
          'tenor': tenor,
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return {
          'success': result['success'],
          'message': result['success']
              ? 'Pinjaman berhasil diupdate'
              : 'Gagal mengupdate pinjaman',
        };
      }
    } catch (e) {
      print('Error editing pinjaman: $e');
    }
    return {'success': false, 'message': 'Gagal mengupdate pinjaman'};
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

  // Method untuk edit cicilan
  static Future<Map<String, dynamic>> editCicilan(
    int cicilanId,
    double jumlah,
    DateTime tanggal,
  ) async {
    try {
      final url = await baseUrl;
      final response = await http.put(
        Uri.parse('$url/cicilan.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'edit',
          'id': cicilanId,
          'jumlah': jumlah,
          'tanggal': tanggal.toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return {
          'success': result['success'] ?? false,
          'message': result['message'] ?? 'Response tidak valid',
        };
      }
    } catch (e) {
      print('Error editing cicilan: $e');
    }
    return {'success': false, 'message': 'Gagal mengedit cicilan'};
  }

  // Method untuk hapus cicilan
  static Future<Map<String, dynamic>> hapusCicilan(int cicilanId) async {
    try {
      final url = await baseUrl;
      final response = await http.delete(
        Uri.parse('$url/cicilan.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': cicilanId}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return {
          'success': result['success'] ?? false,
          'message': result['message'] ?? 'Response tidak valid',
        };
      }
    } catch (e) {
      print('Error deleting cicilan: $e');
    }
    return {'success': false, 'message': 'Gagal menghapus cicilan'};
  }
}
