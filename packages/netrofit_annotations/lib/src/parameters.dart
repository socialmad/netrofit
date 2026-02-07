/// Marks a parameter as the request body.
///
/// Example:
/// ```dart
/// @Post("/users")
/// Future<ApiResult<User>> createUser(@Body() User user);
/// ```
class Body {
  const Body();
}

/// Marks a parameter as a query parameter.
///
/// Example:
/// ```dart
/// @Get("/users")
/// Future<ApiResult<List<User>>> getUsers(@Query('page') int page);
/// ```
class Query {
  /// The name of the query parameter. If null, uses the parameter name.
  final String? name;

  const Query([this.name]);
}

/// Marks a Map parameter as multiple query parameters.
///
/// Example:
/// ```dart
/// @Get("/users")
/// Future<ApiResult<List<User>>> getUsers(@QueryMap() Map<String, dynamic> filters);
/// ```
class QueryMap {
  const QueryMap();
}

/// Marks a parameter as a path parameter.
///
/// Path parameters are extracted from the URL path using curly braces.
///
/// Example:
/// ```dart
/// @Get("/users/{id}")
/// Future<ApiResult<User>> getUser(@Path() int id);
///
/// @Get("/users/{userId}/posts/{postId}")
/// Future<ApiResult<Post>> getPost(@Path('userId') int userId, @Path('postId') int postId);
/// ```
class Path {
  /// The name of the path parameter. If null, uses the parameter name.
  final String? name;

  const Path([this.name]);
}

/// Marks a parameter as a header value.
///
/// Example:
/// ```dart
/// @Get("/users")
/// Future<ApiResult<List<User>>> getUsers(@Header('Authorization') String token);
/// ```
class Header {
  /// The name of the header.
  final String name;

  const Header(this.name);
}

/// Marks a Map parameter as multiple headers.
///
/// Example:
/// ```dart
/// @Get("/users")
/// Future<ApiResult<List<User>>> getUsers(@HeaderMap() Map<String, String> headers);
/// ```
class HeaderMap {
  const HeaderMap();
}

/// Adds static headers to a method.
///
/// Example:
/// ```dart
/// @Get("/users")
/// @Headers({
///   'Content-Type': 'application/json',
///   'Accept': 'application/json',
/// })
/// Future<ApiResult<List<User>>> getUsers();
/// ```
class Headers {
  /// The headers to add to the request.
  final Map<String, String> headers;

  const Headers(this.headers);
}

/// Marks a parameter as a field in a form-encoded request.
///
/// Example:
/// ```dart
/// @Post("/login")
/// @FormUrlEncoded()
/// Future<ApiResult<Token>> login(
///   @Field('username') String username,
///   @Field('password') String password,
/// );
/// ```
class Field {
  /// The name of the field. If null, uses the parameter name.
  final String? name;

  const Field([this.name]);
}

/// Marks a Map parameter as multiple form fields.
///
/// Example:
/// ```dart
/// @Post("/login")
/// @FormUrlEncoded()
/// Future<ApiResult<Token>> login(@FieldMap() Map<String, String> credentials);
/// ```
class FieldMap {
  const FieldMap();
}

/// Marks a method as using form URL encoding.
class FormUrlEncoded {
  const FormUrlEncoded();
}
