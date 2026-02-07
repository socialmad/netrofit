import 'package:netrofit_core/netrofit_core.dart';

/// Interceptor that adds authentication tokens to requests.
///
/// Example:
/// ```dart
/// final authInterceptor = AuthInterceptor(
///   tokenProvider: () => secureStorage.getToken(),
///   headerName: 'Authorization',
///   tokenPrefix: 'Bearer',
/// );
/// ```
class AuthInterceptor implements RequestInterceptor {
  /// Function that provides the authentication token.
  final String? Function() tokenProvider;

  /// The header name to use for the token.
  final String headerName;

  /// Optional prefix for the token (e.g., "Bearer").
  final String? tokenPrefix;

  const AuthInterceptor({
    required this.tokenProvider,
    this.headerName = 'Authorization',
    this.tokenPrefix = 'Bearer',
  });

  @override
  RequestOptions onRequest(RequestOptions options) {
    final token = tokenProvider();
    if (token == null || token.isEmpty) {
      return options;
    }

    final headerValue = tokenPrefix != null ? '$tokenPrefix $token' : token;

    return options.copyWith(
      headers: {
        ...options.headers,
        headerName: headerValue,
      },
    );
  }
}
