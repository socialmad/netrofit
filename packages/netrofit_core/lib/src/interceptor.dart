import 'package:netrofit_result/netrofit_result.dart';
import 'request_options.dart';
import 'raw_response.dart';

/// Base interface for interceptors.
abstract class Interceptor {}

/// Interceptor that can modify requests before they are sent.
abstract class RequestInterceptor implements Interceptor {
  /// Called before a request is sent.
  ///
  /// Return the modified [RequestOptions] or the original if no changes are needed.
  /// Throw an exception to cancel the request.
  RequestOptions onRequest(RequestOptions options);
}

/// Interceptor that can modify responses before they are returned.
abstract class ResponseInterceptor implements Interceptor {
  /// Called after a successful response is received.
  ///
  /// Return the modified [RawResponse] or the original if no changes are needed.
  RawResponse onResponse(RawResponse response, RequestOptions options);
}

/// Interceptor that can handle or modify errors.
abstract class ErrorInterceptor implements Interceptor {
  /// Called when an error occurs.
  ///
  /// Return a modified [ApiError] or the original.
  /// Return null to suppress the error and retry the request.
  ApiError? onError(ApiError error, RequestOptions options);
}

/// Simple function-based request interceptor.
class FunctionRequestInterceptor implements RequestInterceptor {
  final RequestOptions Function(RequestOptions) _handler;

  const FunctionRequestInterceptor(this._handler);

  @override
  RequestOptions onRequest(RequestOptions options) => _handler(options);
}

/// Simple function-based response interceptor.
class FunctionResponseInterceptor implements ResponseInterceptor {
  final RawResponse Function(RawResponse, RequestOptions) _handler;

  const FunctionResponseInterceptor(this._handler);

  @override
  RawResponse onResponse(RawResponse response, RequestOptions options) =>
      _handler(response, options);
}

/// Simple function-based error interceptor.
class FunctionErrorInterceptor implements ErrorInterceptor {
  final ApiError? Function(ApiError, RequestOptions) _handler;

  const FunctionErrorInterceptor(this._handler);

  @override
  ApiError? onError(ApiError error, RequestOptions options) =>
      _handler(error, options);
}
