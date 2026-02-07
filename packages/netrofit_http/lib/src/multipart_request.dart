import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Builder for multipart/form-data requests.
class MultipartRequest {
  final String method;
  final Uri url;
  final Map<String, String> headers;
  final List<MultipartFile> files;
  final Map<String, String> fields;

  MultipartRequest({
    required this.method,
    required this.url,
    this.headers = const {},
    this.files = const [],
    this.fields = const {},
  });

  /// Converts this to an http.MultipartRequest.
  http.MultipartRequest toHttpRequest() {
    final request = http.MultipartRequest(method, url);
    request.headers.addAll(headers);
    request.fields.addAll(fields);

    for (final file in files) {
      request.files.add(file.toHttpMultipartFile());
    }

    return request;
  }
}

/// A file to be uploaded in a multipart request.
class MultipartFile {
  final String field;
  final List<int> bytes;
  final String? filename;
  final String? contentType;

  const MultipartFile({
    required this.field,
    required this.bytes,
    this.filename,
    this.contentType,
  });

  /// Creates a MultipartFile from a File.
  static Future<MultipartFile> fromFile(
    String field,
    File file, {
    String? filename,
    String? contentType,
  }) async {
    final bytes = await file.readAsBytes();
    return MultipartFile(
      field: field,
      bytes: bytes,
      filename: filename ?? file.path.split('/').last,
      contentType: contentType ?? _inferContentType(file.path),
    );
  }

  /// Creates a MultipartFile from bytes.
  static MultipartFile fromBytes(
    String field,
    Uint8List bytes, {
    required String filename,
    String? contentType,
  }) {
    return MultipartFile(
      field: field,
      bytes: bytes,
      filename: filename,
      contentType: contentType ?? _inferContentType(filename),
    );
  }

  /// Converts this to an http.MultipartFile.
  http.MultipartFile toHttpMultipartFile() {
    return http.MultipartFile.fromBytes(
      field,
      bytes,
      filename: filename,
      contentType: contentType != null
          ? http.MediaType.parse(contentType!)
          : null,
    );
  }

  static String _inferContentType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
      case 'json':
        return 'application/json';
      case 'xml':
        return 'application/xml';
      default:
        return 'application/octet-stream';
    }
  }
}
