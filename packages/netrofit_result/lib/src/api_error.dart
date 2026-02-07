/// Base class for all API errors.
abstract class ApiError implements Exception {
  /// Human-readable error message.
  String get message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Type of timeout (connection, send, or receive).
enum TimeoutType {
  connection,
  send,
  receive,
}

/// Type of SSL error.
enum SslErrorType {
  handshakeFailed,
  pinningFailed,
}

/// Network-level failure (no connection, DNS, etc.).
class NetworkError extends ApiError {
  @override
  final String message;

  final Object? cause;
  final StackTrace? stackTrace;

  NetworkError(this.message, {this.cause, this.stackTrace});
}

/// Server returned 5xx or request failed at server.
class ServerError extends ApiError {
  @override
  final String message;

  final int? statusCode;
  final Object? cause;
  final StackTrace? stackTrace;

  ServerError(this.message, {this.statusCode, this.cause, this.stackTrace});

  @override
  String toString() =>
      statusCode != null ? '$runtimeType: $message ($statusCode)' : '$runtimeType: $message';
}

/// Client error (4xx).
class ClientError extends ApiError {
  @override
  final String message;

  final int? statusCode;
  final Object? cause;
  final StackTrace? stackTrace;

  ClientError(this.message, {this.statusCode, this.cause, this.stackTrace});

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 422;
}

/// Request timed out.
class TimeoutError extends ApiError {
  @override
  final String message;

  final Duration? timeout;
  final TimeoutType type;
  final Object? cause;
  final StackTrace? stackTrace;

  TimeoutError(
    this.message, {
    this.timeout,
    this.type = TimeoutType.receive,
    this.cause,
    this.stackTrace,
  });
}

/// Request was cancelled.
class CancellationError extends ApiError {
  final String? reason;

  CancellationError([this.reason]);

  @override
  String get message => reason ?? 'Cancelled';
}

/// SSL/TLS error (handshake, pinning).
class SslError extends ApiError {
  @override
  final String message;

  final SslErrorType type;
  final Object? cause;
  final StackTrace? stackTrace;

  SslError(this.message,
      {this.type = SslErrorType.handshakeFailed, this.cause, this.stackTrace});
}

/// Response body could not be parsed (e.g. JSON).
class ParseError extends ApiError {
  @override
  final String message;

  final String? rawData;
  final Type? expectedType;
  final Object? cause;
  final StackTrace? stackTrace;

  ParseError(this.message,
      {this.rawData, this.expectedType, this.cause, this.stackTrace});
}

/// Unknown or unexpected error.
class UnknownError extends ApiError {
  @override
  final String message;

  final Object? cause;
  final StackTrace? stackTrace;

  UnknownError(this.message, {this.cause, this.stackTrace});
}
