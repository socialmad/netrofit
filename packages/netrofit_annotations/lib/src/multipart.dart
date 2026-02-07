/// Marks a method as using multipart form data.
///
/// Example:
/// ```dart
/// @Post("/upload")
/// @Multipart()
/// Future<ApiResult<UploadResponse>> uploadFile(@Part() File file);
/// ```
class Multipart {
  const Multipart();
}

/// Marks a parameter as a part in a multipart request.
///
/// Example:
/// ```dart
/// @Post("/upload")
/// @Multipart()
/// Future<ApiResult<UploadResponse>> uploadFile(
///   @Part() File file,
///   @Part(name: 'description') String description,
/// );
/// ```
class Part {
  /// The name of the part. If null, uses the parameter name.
  final String? name;

  /// The filename to use for file parts.
  final String? fileName;

  /// The content type for this part.
  final String? contentType;

  const Part({this.name, this.fileName, this.contentType});
}

/// Marks a parameter as a file part in a multipart request.
///
/// This is specifically for file uploads and will handle File, Uint8List,
/// or List<int> types.
///
/// Example:
/// ```dart
/// @Post("/upload")
/// @Multipart()
/// Future<ApiResult<UploadResponse>> uploadFile(
///   @PartFile(name: 'avatar', fileName: 'profile.jpg') File file,
/// );
/// ```
class PartFile {
  /// The name of the part.
  final String name;

  /// The filename to use. If null, will try to extract from File.
  final String? fileName;

  /// The content type. If null, will be inferred from the file extension.
  final String? contentType;

  const PartFile({
    required this.name,
    this.fileName,
    this.contentType,
  });
}

/// Marks a Map parameter as multiple parts in a multipart request.
///
/// Example:
/// ```dart
/// @Post("/upload")
/// @Multipart()
/// Future<ApiResult<UploadResponse>> uploadFiles(
///   @PartMap() Map<String, dynamic> parts,
/// );
/// ```
class PartMap {
  const PartMap();
}

/// Marks a parameter as a progress callback for file upload/download.
///
/// The callback receives a double between 0.0 and 1.0 representing progress.
///
/// Example:
/// ```dart
/// @Post('/upload')
/// @Multipart()
/// Future<ApiResult<File>> uploadFile(
///   @Part() File file,
///   {@Progress() void Function(double progress)? onProgress},
/// );
///
/// @Get('/download/{id}')
/// Future<ApiResult<File>> downloadFile(
///   @Path() String id,
///   {@Progress() void Function(double progress)? onProgress},
/// );
/// ```
class Progress {
  const Progress();
}
