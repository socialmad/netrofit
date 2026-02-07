/// Base class for HTTP method annotations.
abstract class HttpMethod {
  /// The path for this endpoint, relative to the base URL.
  final String path;

  const HttpMethod(this.path);
}

/// Marks a method as a GET request.
///
/// Example:
/// ```dart
/// @Get("/users")
/// Future<ApiResult<List<User>>> getUsers();
///
/// @Get("/users/{id}")
/// Future<ApiResult<User>> getUser(@Path() int id);
/// ```
class Get extends HttpMethod {
  const Get(super.path);
}

/// Marks a method as a POST request.
///
/// Example:
/// ```dart
/// @Post("/users")
/// Future<ApiResult<User>> createUser(@Body() User user);
/// ```
class Post extends HttpMethod {
  const Post(super.path);
}

/// Marks a method as a PUT request.
///
/// Example:
/// ```dart
/// @Put("/users/{id}")
/// Future<ApiResult<User>> updateUser(@Path() int id, @Body() User user);
/// ```
class Put extends HttpMethod {
  const Put(super.path);
}

/// Marks a method as a DELETE request.
///
/// Example:
/// ```dart
/// @Delete("/users/{id}")
/// Future<ApiResult<void>> deleteUser(@Path() int id);
/// ```
class Delete extends HttpMethod {
  const Delete(super.path);
}

/// Marks a method as a PATCH request.
///
/// Example:
/// ```dart
/// @Patch("/users/{id}")
/// Future<ApiResult<User>> patchUser(@Path() int id, @Body() Map<String, dynamic> updates);
/// ```
class Patch extends HttpMethod {
  const Patch(super.path);
}

/// Marks a method as a HEAD request.
///
/// Example:
/// ```dart
/// @Head("/users/{id}")
/// Future<ApiResult<void>> checkUserExists(@Path() int id);
/// ```
class Head extends HttpMethod {
  const Head(super.path);
}
