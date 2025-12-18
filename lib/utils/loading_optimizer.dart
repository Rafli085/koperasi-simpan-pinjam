import 'dart:async';

class LoadingOptimizer {
  // Lazy loading dengan pagination
  static Future<List<T>> loadDataInBatches<T>(
    List<T> data, {
    int batchSize = 50,
    Duration delay = const Duration(milliseconds: 10),
  }) async {
    final List<T> result = [];
    
    for (int i = 0; i < data.length; i += batchSize) {
      final batch = data.skip(i).take(batchSize).toList();
      result.addAll(batch);
      
      // Yield control back to UI thread
      await Future.delayed(delay);
    }
    
    return result;
  }
  
  // Debounced loading untuk search/filter
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }
  
  // Caching untuk data yang sudah diload
  static final Map<String, dynamic> _cache = {};
  
  static T? getCached<T>(String key) {
    return _cache[key] as T?;
  }
  
  static void setCache<T>(String key, T data) {
    _cache[key] = data;
  }
  
  static void clearCache() {
    _cache.clear();
  }
}