/// Raw HTTP response container.
///
/// This is the low-level response object returned by HTTP adapters
/// before being transformed into an [ApiResult].
class RawResponse {
  /// The HTTP status code.
  final int statusCode;

  /// The response body as bytes.
  final List<int> bodyBytes;

  /// The response headers.
  final Map<String, String> headers;

  /// Whether the request was successful (2xx status code).
  final bool isSuccessful;

  const RawResponse({
    required this.statusCode,
    required this.bodyBytes,
    required this.headers,
    required this.isSuccessful,
  });

  /// The response body as a UTF-8 string.
  String get body => String.fromCharCodes(bodyBytes);

  /// Returns the value of a header (case-insensitive).
  String? header(String name) {
    final lowerName = name.toLowerCase();
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == lowerName) {
        return entry.value;
      }
    }
    return null;
  }

  /// Returns the content type of the response.
  String? get contentType => header('content-type');

  /// Returns the content length of the response.
  int? get contentLength {
    final lengthStr = header('content-length');
    return lengthStr != null ? int.tryParse(lengthStr) : null;
  }

  @override
  String toString() {
    return 'RawResponse(statusCode: $statusCode, bodyLength: ${bodyBytes.length}, headers: ${headers.length})';
  }
}
