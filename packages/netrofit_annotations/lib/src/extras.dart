/// Enables caching for a method's response.
///
/// Example:
/// ```dart
/// @Get("/config")
/// @Cache(duration: Duration(hours: 1))
/// Future<ApiResult<AppConfig>> getConfig();
///
/// @Get("/users/{id}")
/// @Cache(duration: Duration(minutes: 5), key: "user_{id}")
/// Future<ApiResult<User>> getUser(@Path() int id);
/// ```
class Cache {
  /// How long to cache the response.
  final Duration duration;

  /// Optional custom cache key. Can include path parameter placeholders.
  final String? key;

  const Cache({
    required this.duration,
    this.key,
  });
}

/// Configures retry behavior for a method.
///
/// Example:
/// ```dart
/// @Get("/data")
/// @Retry(maxAttempts: 3, backoff: Duration(seconds: 1))
/// Future<ApiResult<Data>> getData();
///
/// @Post("/submit")
/// @Retry(
///   maxAttempts: 3,
///   retryWhen: [500, 502, 503, 504],
///   exponentialBackoff: true,
/// )
/// Future<ApiResult<void>> submitData(@Body() Data data);
/// ```
class Retry {
  /// Maximum number of retry attempts.
  final int maxAttempts;

  /// Initial backoff duration between retries.
  final Duration? backoff;

  /// Whether to use exponential backoff (doubles each retry).
  final bool exponentialBackoff;

  /// List of HTTP status codes that should trigger a retry.
  /// If null, retries on any 5xx error.
  final List<int>? retryWhen;

  const Retry({
    required this.maxAttempts,
    this.backoff,
    this.exponentialBackoff = false,
    this.retryWhen,
  });
}

/// Overrides the timeout for a specific method.
///
/// Example:
/// ```dart
/// @Get("/large-file")
/// @Timeout(duration: Duration(minutes: 5))
/// Future<ApiResult<Uint8List>> downloadLargeFile();
/// ```
class Timeout {
  /// The timeout duration.
  final Duration duration;

  /// The type of timeout (connection, send, or receive).
  final TimeoutType type;

  const Timeout({
    required this.duration,
    this.type = TimeoutType.receive,
  });
}

/// The type of timeout.
enum TimeoutType {
  /// Connection timeout.
  connection,

  /// Send timeout.
  send,

  /// Receive timeout.
  receive,
}

/// Marks a method to skip interceptors.
///
/// Example:
/// ```dart
/// @Get("/public/config")
/// @NoInterceptors()
/// Future<ApiResult<Config>> getPublicConfig();
/// ```
class NoInterceptors {
  const NoInterceptors();
}

/// Adds extra metadata to a request that can be accessed by interceptors.
///
/// Example:
/// ```dart
/// @Get("/users")
/// @Extra({'requiresAuth': true, 'cacheKey': 'users'})
/// Future<ApiResult<List<User>>> getUsers();
/// ```
class Extra {
  /// The extra metadata.
  final Map<String, dynamic> data;

  const Extra(this.data);
}
