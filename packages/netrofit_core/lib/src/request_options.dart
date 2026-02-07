import 'cancel_token.dart';

/// Options for an HTTP request.
class RequestOptions {
  /// The HTTP method (GET, POST, etc.).
  final String method;

  /// The full URL for the request.
  final String url;

  /// The request headers.
  final Map<String, String> headers;

  /// The request body (for POST, PUT, PATCH).
  final dynamic body;

  /// Query parameters.
  final Map<String, dynamic> queryParameters;

  /// Connection timeout.
  final Duration? connectTimeout;

  /// Receive timeout.
  final Duration? receiveTimeout;

  /// Send timeout.
  final Duration? sendTimeout;

  /// Whether to follow redirects.
  final bool followRedirects;

  /// Maximum number of redirects.
  final int maxRedirects;

  /// Cancel token for this request.
  final CancelToken? cancelToken;

  /// Extra metadata that can be used by interceptors.
  final Map<String, dynamic> extra;

  const RequestOptions({
    required this.method,
    required this.url,
    this.headers = const {},
    this.body,
    this.queryParameters = const {},
    this.connectTimeout,
    this.receiveTimeout,
    this.sendTimeout,
    this.followRedirects = true,
    this.maxRedirects = 5,
    this.cancelToken,
    this.extra = const {},
  });

  /// Creates a copy of this request with the given fields replaced.
  RequestOptions copyWith({
    String? method,
    String? url,
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    bool? followRedirects,
    int? maxRedirects,
    CancelToken? cancelToken,
    Map<String, dynamic>? extra,
  }) {
    return RequestOptions(
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      queryParameters: queryParameters ?? this.queryParameters,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
      cancelToken: cancelToken ?? this.cancelToken,
      extra: extra ?? this.extra,
    );
  }

  @override
  String toString() {
    return 'RequestOptions(method: $method, url: $url, headers: ${headers.length}, hasBody: ${body != null})';
  }
}
