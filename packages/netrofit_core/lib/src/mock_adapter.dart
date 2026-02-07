import 'package:netrofit_core/netrofit_core.dart';

/// Mock HTTP adapter for testing without making real network requests.
///
/// Example:
/// ```dart
/// final mockAdapter = MockAdapter({
///   '/users': MockResponse(
///     body: '[{"id": 1, "name": "Test User"}]',
///     statusCode: 200,
///   ),
///   '/users/1': MockResponse(
///     body: '{"id": 1, "name": "Test User"}',
///     delay: Duration(milliseconds: 100),
///   ),
/// });
///
/// final api = UserApi(httpAdapter: mockAdapter);
/// ```
class MockAdapter implements HttpAdapter {
  final Map<String, MockResponse> _responses;
  final MockResponse? _defaultResponse;

  MockAdapter(
    this._responses, {
    MockResponse? defaultResponse,
  }) : _defaultResponse = defaultResponse;

  @override
  Future<RawResponse> get(RequestOptions options) =>
      _handleRequest('GET', options);

  @override
  Future<RawResponse> post(RequestOptions options) =>
      _handleRequest('POST', options);

  @override
  Future<RawResponse> put(RequestOptions options) =>
      _handleRequest('PUT', options);

  @override
  Future<RawResponse> delete(RequestOptions options) =>
      _handleRequest('DELETE', options);

  @override
  Future<RawResponse> patch(RequestOptions options) =>
      _handleRequest('PATCH', options);

  @override
  Future<RawResponse> head(RequestOptions options) =>
      _handleRequest('HEAD', options);

  Future<RawResponse> _handleRequest(
    String method,
    RequestOptions options,
  ) async {
    // Find matching response
    final response = _responses[options.url] ?? _defaultResponse;

    if (response == null) {
      return RawResponse(
        statusCode: 404,
        bodyBytes: '{"error": "Not found"}'.codeUnits,
        headers: {},
        isSuccessful: false,
      );
    }

    // Simulate network delay
    if (response.delay != null) {
      await Future.delayed(response.delay!);
    }

    return RawResponse(
      statusCode: response.statusCode,
      bodyBytes: response.body.codeUnits,
      headers: response.headers,
      isSuccessful: response.statusCode >= 200 && response.statusCode < 300,
    );
  }

  @override
  void close() {
    // No resources to clean up for mock adapter
  }
}

/// Mock response configuration.
class MockResponse {
  /// Response body (JSON string or any string).
  final String body;

  /// HTTP status code (default: 200).
  final int statusCode;

  /// Response headers.
  final Map<String, String> headers;

  /// Simulated network delay.
  final Duration? delay;

  const MockResponse({
    required this.body,
    this.statusCode = 200,
    this.headers = const {},
    this.delay,
  });

  /// Creates a success response with JSON body.
  factory MockResponse.success({
    required String body,
    Map<String, String>? headers,
    Duration? delay,
  }) =>
      MockResponse(
        body: body,
        statusCode: 200,
        headers: headers ?? {},
        delay: delay,
      );

  /// Creates an error response.
  factory MockResponse.error({
    required String message,
    int statusCode = 500,
    Map<String, String>? headers,
    Duration? delay,
  }) =>
      MockResponse(
        body: '{"error": "$message"}',
        statusCode: statusCode,
        headers: headers ?? {},
        delay: delay,
      );
}
