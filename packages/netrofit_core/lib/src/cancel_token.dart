import 'package:netrofit_result/netrofit_result.dart';

/// Token for cancelling requests.
///
/// Example:
/// ```dart
/// final cancelToken = CancelToken();
/// final future = api.getUsers(cancelToken: cancelToken);
///
/// // Cancel the request
/// cancelToken.cancel('User navigated away');
/// ```
class CancelToken {
  bool _isCancelled = false;
  String? _reason;
  final List<void Function()> _listeners = [];

  /// Whether this token has been cancelled.
  bool get isCancelled => _isCancelled;

  /// The reason for cancellation, if provided.
  String? get reason => _reason;

  /// Cancels this token with an optional reason.
  void cancel([String? reason]) {
    if (_isCancelled) return;

    _isCancelled = true;
    _reason = reason;

    // Notify all listeners
    for (final listener in _listeners) {
      try {
        listener();
      } catch (_) {
        // Ignore errors in listeners
      }
    }
    _listeners.clear();
  }

  /// Adds a listener that will be called when this token is cancelled.
  void addListener(void Function() listener) {
    if (_isCancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
  }

  /// Removes a listener.
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  /// Throws a [CancellationError] if this token has been cancelled.
  void throwIfCancelled() {
    if (_isCancelled) {
      throw CancellationError(_reason ?? 'Request was cancelled');
    }
  }
}
