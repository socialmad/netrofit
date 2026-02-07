/// Annotation for paginated API endpoints.
///
/// Example:
/// ```dart
/// @Get('/users')
/// @Paginated(pageSize: 20)
/// Future<ApiResult<List<User>>> getUsers(@Page() int page);
/// ```
class Paginated {
  /// Default page size for pagination.
  final int pageSize;

  /// Query parameter name for page number (default: 'page').
  final String pageParam;

  /// Query parameter name for page size (default: 'limit').
  final String sizeParam;

  const Paginated({
    this.pageSize = 20,
    this.pageParam = 'page',
    this.sizeParam = 'limit',
  });
}

/// Marks a parameter as the page number for pagination.
///
/// Example:
/// ```dart
/// Future<ApiResult<List<User>>> getUsers(@Page() int page);
/// ```
class Page {
  /// Optional custom query parameter name.
  final String? name;

  const Page([this.name]);
}

/// Marks a parameter as the page size/limit for pagination.
///
/// Example:
/// ```dart
/// Future<ApiResult<List<User>>> getUsers(
///   @Page() int page,
///   @PageSize() int limit,
/// );
/// ```
class PageSize {
  /// Optional custom query parameter name.
  final String? name;

  const PageSize([this.name]);
}
