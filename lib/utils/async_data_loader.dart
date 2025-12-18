import 'dart:async';
import 'dart:isolate';

class AsyncDataLoader {
  static Future<List<Map<String, dynamic>>> loadCityDataAsync(String rawData) async {
    final completer = Completer<List<Map<String, dynamic>>>();
    
    await Isolate.spawn(_parseDataInIsolate, {
      'data': rawData,
      'sendPort': completer.future.then((result) => result).toString(),
    });
    
    return completer.future;
  }
  
  static void _parseDataInIsolate(Map<String, dynamic> params) {
    final String data = params['data'];
    final List<Map<String, dynamic>> cities = [];
    
    // Parse data dalam batch untuk menghindari blocking UI
    final lines = data.split('\n');
    for (int i = 0; i < lines.length; i += 50) { // Process 50 items at a time
      final batch = lines.skip(i).take(50);
      for (final line in batch) {
        if (line.isNotEmpty) {
          cities.add(_parseCityLine(line));
        }
      }
    }
  }
  
  static Map<String, dynamic> _parseCityLine(String line) {
    final parts = line.split(',');
    if (parts.length >= 5) {
      return {
        'name': parts[0].split('=')[1],
        'timezone': parts[1].trim(),
        'country': parts[2].trim(),
        'latitude': double.tryParse(parts[3].trim()) ?? 0.0,
        'longitude': double.tryParse(parts[4].trim()) ?? 0.0,
      };
    }
    return {};
  }
}