import 'package:netrofit_core/netrofit_core.dart';

/// Simple in-memory cache for responses.
abstract class ResponseCache {
  /// Gets a cached response for the given key.
  RawResponse? get(String key);

  /// Stores a response in the cache.
  void set(String key, RawResponse response, Duration duration);

  /// Clears the cache.
  void clear();

  /// Removes a specific key from the cache.
  void remove(String key);
}

/// In-memory implementation of ResponseCache.
class MemoryCache implements ResponseCache {
  final Map<String, _CacheEntry> _cache = {};

  @override
  RawResponse? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.response;
  }

  @override
  void set(String key, RawResponse response, Duration duration) {
    _cache[key] = _CacheEntry(
      response: response,
      expiresAt: DateTime.now().add(duration),
    );
  }

  @override
  void clear() {
    _cache.clear();
  }

  @override
  void remove(String key) {
    _cache.remove(key);
  }
}

class _CacheEntry {
  final RawResponse response;
  final DateTime expiresAt;

  _CacheEntry({required this.response, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Interceptor that caches responses.
///
/// Example:
/// ```dart
/// final cacheInterceptor = CacheInterceptor(
///   cache: MemoryCache(),
///   defaultDuration: Duration(minutes: 5),
/// );
/// ```
class CacheInterceptor implements RequestInterceptor, ResponseInterceptor {
  /// The cache implementation to use.
  final ResponseCache cache;

  /// Default cache duration if not specified in request.
  final Duration defaultDuration;

  /// HTTP methods that should be cached.
  final List<String> cacheableMethods;

  const CacheInterceptor({
    required this.cache,
    this.defaultDuration = const Duration(minutes: 5),
    this.cacheableMethods = const ['GET'],
  });

  @override
  RequestOptions onRequest(RequestOptions options) {
    // Only cache GET requests by default
    if (!cacheableMethods.contains(options.method.toUpperCase())) {
      return options;
    }

    // Check if there's a cached response
    final cacheKey = _buildCacheKey(options);
    final cachedResponse = cache.get(cacheKey);

    if (cachedResponse != null) {
      // Store cached response in extra for later retrieval
      return options.copyWith(
        extra: {
          ...options.extra,
          '_cachedResponse': cachedResponse,
        },
      );
    }

    return options;
  }

  @override
  RawResponse onResponse(RawResponse response, RequestOptions options) {
    // Only cache successful responses
    if (!response.isSuccessful) {
      return response;
    }

    // Only cache GET requests by default
    if (!cacheableMethods.contains(options.method.toUpperCase())) {
      return response;
    }

    // Get cache duration from extra or use default
    final duration = options.extra['_cacheDuration'] as Duration? ?? defaultDuration;

    // Store in cache
    final cacheKey = _buildCacheKey(options);
    cache.set(cacheKey, response, duration);

    return response;
  }

  String _buildCacheKey(RequestOptions options) {
    // Build a cache key from URL and query parameters
    final queryString = options.queryParameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return queryString.isEmpty
        ? options.url
        : '${options.url}?$queryString';
  }
}
