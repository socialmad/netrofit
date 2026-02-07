import 'api_error.dart';

/// Result of an API call: either success with [data] or failure with [error].
class ApiResult<T> {
  final T? _data;
  final ApiError? _error;
  final int? _statusCode;
  final Map<String, String>? _headers;

  const ApiResult._({
    T? data,
    ApiError? error,
    int? statusCode,
    Map<String, String>? headers,
  })  : _data = data,
        _error = error,
        _statusCode = statusCode,
        _headers = headers;

  /// Creates a successful result with [data] and optional [statusCode] and [headers].
  factory ApiResult.success({
    required T? data,
    int? statusCode,
    Map<String, String>? headers,
  }) =>
      ApiResult._(
        data: data,
        statusCode: statusCode,
        headers: headers,
      );

  /// Creates a failed result with [error] and optional [statusCode].
  factory ApiResult.failure({
    required ApiError error,
    int? statusCode,
  }) =>
      ApiResult._(error: error, statusCode: statusCode);

  bool get isSuccess => _error == null;
  bool get isFailure => _error != null;
  bool get hasData => _data != null;
  bool get hasError => _error != null;

  T? get data => _data;
  ApiError? get error => _error;
  int? get statusCode => _statusCode;
  Map<String, String>? get headers => _headers;

  bool get isNetworkError => _error is NetworkError;
  bool get isServerError => _error is ServerError;
  bool get isClientError => _error is ClientError;
  bool get isTimeoutError => _error is TimeoutError;
  bool get isCancelled => _error is CancellationError;
  bool get isSslError => _error is SslError;

  /// Pattern-match on success or failure.
  R when<R>({
    required R Function(T data) success,
    required R Function(ApiError error) failure,
  }) {
    final err = _error;
    if (err != null) {
      return failure(err);
    }
    return success(_data as T);
  }

  /// Transform the success value; preserves failure.
  ApiResult<R> map<R>(R Function(T data) transform) {
    final err = _error;
    if (err != null) {
      return ApiResult.failure(error: err, statusCode: _statusCode);
    }
    return ApiResult.success(
      data: transform(_data as T),
      statusCode: _statusCode,
      headers: _headers,
    );
  }

  /// Returns [data] if success, otherwise [defaultValue].
  T getOrElse(T defaultValue) => _data ?? defaultValue;

  /// Returns [data] if success; throws [error] if failure.
  T getOrThrow() {
    final err = _error;
    if (err != null) throw err;
    return _data as T;
  }

  /// Fold: [onFailure] for error, [onSuccess] for data.
  R fold<R>(
      R Function(ApiError error) onFailure, R Function(T data) onSuccess) {
    final err = _error;
    if (err != null) return onFailure(err);
    return onSuccess(_data as T);
  }

  /// Execute [onSuccess] with data when successful; no-op on failure.
  ApiResult<T> onSuccess(void Function(T data) onSuccess) {
    if (_error == null) {
      onSuccess(_data as T);
    }
    return this;
  }

  /// Convenience getter: returns data if success, null if failure.
  T? get dataOrNull => _error == null ? _data : null;

  /// Convenience getter: returns error if failure, null if success.
  ApiError? get errorOrNull => _error;

  /// Unwraps the result, throwing the error if failure.
  /// Alias for getOrThrow() with a more intuitive name.
  T unwrap() => getOrThrow();

  /// FlatMap: transform success value to another ApiResult.
  /// Useful for chaining API calls.
  ApiResult<R> flatMap<R>(ApiResult<R> Function(T data) transform) {
    final err = _error;
    if (err != null) {
      return ApiResult.failure(error: err, statusCode: _statusCode);
    }
    return transform(_data as T);
  }

  /// Async version of flatMap for chaining async operations.
  Future<ApiResult<R>> thenAsync<R>(
    Future<ApiResult<R>> Function(T data) transform,
  ) async {
    final err = _error;
    if (err != null) {
      return ApiResult.failure(error: err, statusCode: _statusCode);
    }
    return transform(_data as T);
  }

  /// Execute [onFailure] with error when failed; no-op on success.
  ApiResult<T> onFailure(void Function(ApiError error) onFailure) {
    final err = _error;
    if (err != null) {
      onFailure(err);
    }
    return this;
  }

  @override
  String toString() {
    if (_error != null) {
      return 'ApiResult.failure(error: $_error, statusCode: $_statusCode)';
    }
    return 'ApiResult.success(data: $_data, statusCode: $_statusCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResult<T> &&
        other._data == _data &&
        other._error == _error &&
        other._statusCode == _statusCode;
  }

  @override
  int get hashCode => Object.hash(_data, _error, _statusCode);
}
