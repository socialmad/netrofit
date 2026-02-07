import 'raw_response.dart';
import 'request_options.dart';

/// Abstract HTTP adapter interface.
///
/// Implementations of this interface handle the actual HTTP communication.
abstract class HttpAdapter {
  /// Performs a GET request.
  Future<RawResponse> get(RequestOptions options);

  /// Performs a POST request.
  Future<RawResponse> post(RequestOptions options);

  /// Performs a PUT request.
  Future<RawResponse> put(RequestOptions options);

  /// Performs a DELETE request.
  Future<RawResponse> delete(RequestOptions options);

  /// Performs a PATCH request.
  Future<RawResponse> patch(RequestOptions options);

  /// Performs a HEAD request.
  Future<RawResponse> head(RequestOptions options);

  /// Closes the adapter and releases any resources.
  void close();
}
