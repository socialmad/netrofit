import 'package:netrofit_core/netrofit_core.dart';
import 'package:netrofit_result/netrofit_result.dart';

/// Interceptor that automatically retries failed requests.
///
/// Example:
/// ```dart
/// final retryInterceptor = RetryInterceptor(
///   maxRetries: 3,
///   retryableStatusCodes: [500, 502, 503, 504],
///   backoff: Duration(seconds: 1),
///   exponentialBackoff: true,
/// );
/// ```
class RetryInterceptor implements ErrorInterceptor {
  /// Maximum number of retry attempts.
  final int maxRetries;

  /// HTTP status codes that should trigger a retry.
  final List<int> retryableStatusCodes;

  /// Initial backoff duration between retries.
  final Duration backoff;

  /// Whether to use exponential backoff.
  final bool exponentialBackoff;

  /// Function to determine if an error should be retried.
  final bool Function(ApiError error)? shouldRetry;

  const RetryInterceptor({
    this.maxRetries = 3,
    this.retryableStatusCodes = const [500, 502, 503, 504],
    this.backoff = const Duration(seconds: 1),
    this.exponentialBackoff = false,
    this.shouldRetry,
  });

  int _getRetryCount(RequestOptions options) {
    return options.extra['_retryCount'] as int? ?? 0;
  }

  @override
  ApiError? onError(ApiError error, RequestOptions options) {
    final retryCount = _getRetryCount(options);

    if (retryCount >= maxRetries) {
      return error; // Max retries reached
    }

    // Check if we should retry this error
    bool shouldRetryError = false;

    if (shouldRetry != null) {
      shouldRetryError = shouldRetry!(error);
    } else {
      // Default retry logic
      if (error is ServerError) {
        shouldRetryError = retryableStatusCodes.contains(error.statusCode);
      } else if (error is NetworkError || error is TimeoutError) {
        shouldRetryError = true;
      }
    }

    if (!shouldRetryError) {
      return error;
    }

    // Calculate backoff duration
    final delay = exponentialBackoff
        ? backoff * (1 << retryCount) // 2^retryCount
        : backoff;

    // Sleep before retry
    Future.delayed(delay);

    // Return null to signal retry; adapter will call _executeRequest(options) again
    return null;
  }
}
