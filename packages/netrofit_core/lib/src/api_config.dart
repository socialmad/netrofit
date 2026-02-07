/// Configuration for API clients.
class ApiConfig {
  /// Base URL for the API.
  final String? baseUrl;

  /// Connection timeout.
  final Duration? connectTimeout;

  /// Receive timeout.
  final Duration? receiveTimeout;

  /// Send timeout.
  final Duration? sendTimeout;

  /// Default headers to include in all requests.
  final Map<String, String>? defaultHeaders;

  /// Whether to follow redirects.
  final bool followRedirects;

  /// Maximum number of redirects to follow.
  final int maxRedirects;

  const ApiConfig({
    this.baseUrl,
    this.connectTimeout,
    this.receiveTimeout,
    this.sendTimeout,
    this.defaultHeaders,
    this.followRedirects = true,
    this.maxRedirects = 5,
  });

  /// Creates a copy of this config with the given fields replaced.
  ApiConfig copyWith({
    String? baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? defaultHeaders,
    bool? followRedirects,
    int? maxRedirects,
  }) {
    return ApiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
    );
  }
}
