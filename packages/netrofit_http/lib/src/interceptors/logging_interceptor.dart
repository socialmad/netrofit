import 'package:netrofit_core/netrofit_core.dart';

/// Log level for the logging interceptor.
enum LogLevel {
  /// No logging.
  none,

  /// Log only basic info (method, URL, status code).
  basic,

  /// Log headers in addition to basic info.
  headers,

  /// Log full request and response bodies.
  body,
}

/// Interceptor that logs HTTP requests and responses.
///
/// Example:
/// ```dart
/// final loggingInterceptor = LoggingInterceptor(
///   level: LogLevel.body,
///   logPrint: (message) => print(message),
/// );
/// ```
class LoggingInterceptor implements RequestInterceptor, ResponseInterceptor {
  /// The log level.
  final LogLevel level;

  /// Function to use for logging. Defaults to print.
  final void Function(String message) logPrint;

  const LoggingInterceptor({
    this.level = LogLevel.basic,
    this.logPrint = print,
  });

  @override
  RequestOptions onRequest(RequestOptions options) {
    if (level == LogLevel.none) return options;

    final buffer = StringBuffer();
    buffer.writeln('┌─── Request ────────────────────────────────────────');
    buffer.writeln('│ ${options.method} ${options.url}');

    if (level == LogLevel.headers || level == LogLevel.body) {
      if (options.headers.isNotEmpty) {
        buffer.writeln('│ Headers:');
        options.headers.forEach((key, value) {
          buffer.writeln('│   $key: $value');
        });
      }
    }

    if (level == LogLevel.body && options.body != null) {
      buffer.writeln('│ Body:');
      buffer.writeln('│   ${options.body}');
    }

    buffer.writeln('└────────────────────────────────────────────────────');
    logPrint(buffer.toString());

    return options;
  }

  @override
  RawResponse onResponse(RawResponse response, RequestOptions options) {
    if (level == LogLevel.none) return response;

    final buffer = StringBuffer();
    buffer.writeln('┌─── Response ───────────────────────────────────────');
    buffer.writeln('│ ${options.method} ${options.url}');
    buffer.writeln('│ Status: ${response.statusCode}');

    if (level == LogLevel.headers || level == LogLevel.body) {
      if (response.headers.isNotEmpty) {
        buffer.writeln('│ Headers:');
        response.headers.forEach((key, value) {
          buffer.writeln('│   $key: $value');
        });
      }
    }

    if (level == LogLevel.body) {
      buffer.writeln('│ Body:');
      final body = response.body;
      if (body.length > 1000) {
        buffer.writeln('│   ${body.substring(0, 1000)}... (truncated)');
      } else {
        buffer.writeln('│   $body');
      }
    }

    buffer.writeln('└────────────────────────────────────────────────────');
    logPrint(buffer.toString());

    return response;
  }
}
