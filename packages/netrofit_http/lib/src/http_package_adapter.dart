import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:netrofit_core/netrofit_core.dart';
import 'package:netrofit_result/netrofit_result.dart';
import 'ssl_config.dart';

/// Default HTTP adapter implementation using package:http.
class HttpPackageAdapter implements HttpAdapter {
  final http.Client _client;
  final ApiConfig? baseConfig;
  final SslConfig? sslConfig;
  final List<Interceptor> _interceptors;

  HttpPackageAdapter({
    http.Client? client,
    this.baseConfig,
    this.sslConfig,
    List<Interceptor>? interceptors,
  })  : _client = client ?? _createClient(sslConfig),
        _interceptors = interceptors ?? [];

  static http.Client _createClient(SslConfig? sslConfig) {
    if (sslConfig != null && sslConfig.isEnabled) {
      // For SSL pinning, we need to use HttpClient with custom SecurityContext
      final httpClient = HttpClient();

      if (sslConfig.allowSelfSigned) {
        httpClient.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      }

      // Note: Full SSL pinning implementation would require platform-specific code
      // This is a simplified version that sets up the HttpClient
      return http.Client();
    }
    return http.Client();
  }

  /// Adds a request interceptor using a simple function.
  void addRequestInterceptor(RequestOptions Function(RequestOptions) handler) {
    _interceptors.add(FunctionRequestInterceptor(handler));
  }

  /// Adds a response interceptor using a simple function.
  void addResponseInterceptor(
      RawResponse Function(RawResponse, RequestOptions) handler) {
    _interceptors.add(FunctionResponseInterceptor(handler));
  }

  /// Adds an error interceptor using a simple function.
  void addErrorInterceptor(
      ApiError? Function(ApiError, RequestOptions) handler) {
    _interceptors.add(FunctionErrorInterceptor(handler));
  }

  @override
  Future<RawResponse> get(RequestOptions options) =>
      _executeRequest(options.copyWith(method: 'GET'));

  @override
  Future<RawResponse> post(RequestOptions options) =>
      _executeRequest(options.copyWith(method: 'POST'));

  @override
  Future<RawResponse> put(RequestOptions options) =>
      _executeRequest(options.copyWith(method: 'PUT'));

  @override
  Future<RawResponse> delete(RequestOptions options) =>
      _executeRequest(options.copyWith(method: 'DELETE'));

  @override
  Future<RawResponse> patch(RequestOptions options) =>
      _executeRequest(options.copyWith(method: 'PATCH'));

  @override
  Future<RawResponse> head(RequestOptions options) =>
      _executeRequest(options.copyWith(method: 'HEAD'));

  Future<RawResponse> _executeRequest(RequestOptions options) async {
    // Apply request interceptors
    var modifiedOptions = options;
    for (final interceptor in _interceptors) {
      if (interceptor is RequestInterceptor) {
        modifiedOptions = interceptor.onRequest(modifiedOptions);
      }
    }

    // Check for cancellation
    modifiedOptions.cancelToken?.throwIfCancelled();

    try {
      // Build the URI with query parameters
      final uri = _buildUri(modifiedOptions.url, modifiedOptions.queryParameters);

      // Create the request
      final request = http.Request(modifiedOptions.method, uri);

      // Add headers
      request.headers.addAll(modifiedOptions.headers);

      // Add body if present
      if (modifiedOptions.body != null) {
        if (modifiedOptions.body is String) {
          request.body = modifiedOptions.body as String;
        } else if (modifiedOptions.body is Map) {
          request.body = jsonEncode(modifiedOptions.body);
          request.headers['content-type'] = 'application/json';
        } else if (modifiedOptions.body is List<int>) {
          request.bodyBytes = modifiedOptions.body as List<int>;
        }
      }

      // Send the request with timeout
      final streamedResponse = await _sendWithTimeout(
        request,
        modifiedOptions.receiveTimeout ?? baseConfig?.receiveTimeout,
      );

      // Read the response
      final responseBytes = await streamedResponse.stream.toBytes();

      var rawResponse = RawResponse(
        statusCode: streamedResponse.statusCode,
        bodyBytes: responseBytes,
        headers: streamedResponse.headers,
        isSuccessful: streamedResponse.statusCode >= 200 &&
            streamedResponse.statusCode < 300,
      );

      // Apply response interceptors
      for (final interceptor in _interceptors) {
        if (interceptor is ResponseInterceptor) {
          rawResponse = interceptor.onResponse(rawResponse, modifiedOptions);
        }
      }

      return rawResponse;
    } on TimeoutException catch (e, stackTrace) {
      final error = TimeoutError(
        'Request timeout: ${e.message}',
        timeout: modifiedOptions.receiveTimeout,
        type: TimeoutType.receive,
        cause: e,
        stackTrace: stackTrace,
      );
      return _handleError(error, modifiedOptions);
    } on SocketException catch (e, stackTrace) {
      final error = NetworkError(
        'Network error: ${e.message}',
        cause: e,
        stackTrace: stackTrace,
      );
      return _handleError(error, modifiedOptions);
    } on HandshakeException catch (e, stackTrace) {
      final error = SslError(
        'SSL handshake failed: ${e.message}',
        type: SslErrorType.handshakeFailed,
        cause: e,
        stackTrace: stackTrace,
      );
      return _handleError(error, modifiedOptions);
    } on CancellationError {
      rethrow;
    } catch (e, stackTrace) {
      final error = UnknownError(
        'Unknown error: $e',
        cause: e,
        stackTrace: stackTrace,
      );
      return _handleError(error, modifiedOptions);
    }
  }

  Future<http.StreamedResponse> _sendWithTimeout(
    http.Request request,
    Duration? timeout,
  ) async {
    if (timeout != null) {
      return _client.send(request).timeout(timeout);
    }
    return _client.send(request);
  }

  Uri _buildUri(String url, Map<String, dynamic> queryParameters) {
    final uri = Uri.parse(url);
    if (queryParameters.isEmpty) {
      return uri;
    }

    final queryParams = <String, String>{};
    queryParameters.forEach((key, value) {
      queryParams[key] = value.toString();
    });

    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams,
    });
  }

  Future<RawResponse> _handleError(
    ApiError error,
    RequestOptions options,
  ) async {
    var modifiedError = error;

    // Apply error interceptors
    for (final interceptor in _interceptors) {
      if (interceptor is ErrorInterceptor) {
        final result = interceptor.onError(modifiedError, options);
        if (result == null) {
          // Interceptor wants to suppress the error and retry
          return _executeRequest(options);
        }
        modifiedError = result;
      }
    }

    // Return a failed response
    throw modifiedError;
  }

  @override
  void close() {
    _client.close();
  }
}
