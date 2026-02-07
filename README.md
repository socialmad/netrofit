# Netrofit

**Type-safe HTTP client for Dart & Flutter** with annotation-based API definitions and code generation. Define your REST API once, generate type-safe code, and get automatic error handling.

[![Dart](https://img.shields.io/badge/dart-%3E%3D3.5-blue.svg)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/flutter-%3E%3D3.27-blue.svg)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Why Netrofit?

- 🎯 **Type-Safe**: Compile-time safety for all API calls
- 🚀 **Zero Boilerplate**: Define APIs with annotations, generate implementation
- 💪 **Powerful**: Built-in interceptors, retry logic, SSL pinning, mocking
- 🔄 **Result Type**: Elegant `ApiResult<T>` for success/failure handling
- 📦 **Single Package**: Just add `netrofit_all` - that's it!

---

## 🚀 Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  netrofit_all: ^1.0.0        # All-in-one package
  json_annotation: ^4.9.0      # For JSON serialization

dev_dependencies:
  netrofit_generator: ^1.0.0   # Code generator
  build_runner: ^2.4.0         # Build system
  json_serializable: ^6.8.0    # JSON code generator
```

Then run:
```bash
flutter pub get
```

### Define Your API

Create your API interface with annotations:

```dart
// lib/api/users_api.dart
import 'dart:convert';  // Required for jsonDecode

import 'package:netrofit_all/netrofit_all.dart';
import '../models/user.dart';

part 'users_api.netrofit.g.dart';

@RestApi(baseUrl: 'https://api.example.com')
abstract class UsersApi {
  factory UsersApi({required HttpAdapter httpAdapter}) = _$UsersApiImpl;

  @Get('/users')
  Future<ApiResult<List<User>>> getUsers();

  @Get('/users/{id}')
  Future<ApiResult<User>> getUser(@Path() int id);

  @Post('/users')
  Future<ApiResult<User>> createUser(@Body() User user);
}
```

### Generate Code

Run the code generator:

```bash
# Clean previous builds (recommended)
dart run build_runner clean

# Generate implementation
dart run build_runner build --delete-conflicting-outputs

# Rename the generated file (required)
mv lib/api/users_api.netrofit.g.part lib/api/users_api.netrofit.g.dart
```

> **Note**: The generator creates a `.part` file that needs to be renamed to `.g.dart`. This is a known limitation we're working to fix.

### Use Your API

```dart
// Initialize the API
final httpAdapter = HttpPackageAdapter(
  interceptors: [LoggingInterceptor(level: LogLevel.basic)],
);
final api = UsersApi(httpAdapter: httpAdapter);

// Make API calls
final result = await api.getUsers();

// Handle the result
result.when(
  success: (users) => print('Got ${users.length} users'),
  failure: (error) => print('Error: ${error.message}'),
);
```

**That's it!** 🎉 No manual HTTP code, no JSON parsing, no error handling boilerplate.

---

## 📖 Step-by-Step Guide

### Step 1: Create Your Model

```dart
// lib/models/user.dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

### Step 2: Define API Endpoints

```dart
// lib/api/users_api.dart
import 'package:netrofit_all/netrofit_all.dart';
import '../models/user.dart';

part 'users_api.netrofit.g.dart';

@RestApi(baseUrl: 'https://jsonplaceholder.typicode.com')
abstract class UsersApi {
  factory UsersApi({required HttpAdapter httpAdapter}) = _$UsersApiImpl;

  // GET request
  @Get('/users')
  Future<ApiResult<List<User>>> getUsers();

  // GET with path parameter
  @Get('/users/{id}')
  Future<ApiResult<User>> getUser(@Path() int id);

  // POST with body
  @Post('/users')
  Future<ApiResult<User>> createUser(@Body() User user);

  // PUT with path and body
  @Put('/users/{id}')
  Future<ApiResult<User>> updateUser(@Path() int id, @Body() User user);

  // DELETE
  @Delete('/users/{id}')
  Future<ApiResult<void>> deleteUser(@Path() int id);

  // Query parameters
  @Get('/users')
  Future<ApiResult<List<User>>> searchUsers(@Query('name') String name);
}
```

### Step 3: Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates `users_api.netrofit.g.dart` and `user.g.dart` automatically!

### Step 4: Initialize and Use

```dart
import 'package:netrofit_all/netrofit_all.dart';
import 'api/users_api.dart';

void main() async {
  // Create HTTP adapter with interceptors
  final httpAdapter = HttpPackageAdapter(
    interceptors: [
      LoggingInterceptor(level: LogLevel.basic),
      RetryInterceptor(maxRetries: 3),
    ],
  );

  // Create API instance
  final api = UsersApi(httpAdapter: httpAdapter);

  // Make API calls
  final result = await api.getUsers();

  // Handle result
  result.when(
    success: (users) {
      print('Success! Got ${users.length} users');
      for (var user in users) {
        print('- ${user.name} (${user.email})');
      }
    },
    failure: (error) {
      print('Error: ${error.message}');
      if (error is NetworkError) {
        print('Network issue - check your connection');
      } else if (error is ServerError) {
        print('Server error: ${error.statusCode}');
      }
    },
  );
}
```

---

## 🎯 Core Features

### ApiResult - Elegant Error Handling

```dart
// Pattern matching
result.when(
  success: (data) => handleSuccess(data),
  failure: (error) => handleError(error),
);

// Convenience methods
final user = result.dataOrNull;  // Returns data or null
final error = result.errorOrNull;  // Returns error or null

try {
  final user = result.unwrap();  // Throws on error
  print(user.name);
} catch (e) {
  print('Failed: $e');
}

// Chain API calls
final posts = await api.getUser(1)
    .then((r) => r.flatMap((user) => api.getUserPosts(user.id)));

// Async chaining
final result = await api.getUser(1)
    .then((r) => r.thenAsync((user) async {
      return api.getUserPosts(user.id);
    }));
```

### Interceptors

```dart
final httpAdapter = HttpPackageAdapter(
  interceptors: [
    // Logging
    LoggingInterceptor(level: LogLevel.body),

    // Authentication
    AuthInterceptor(tokenProvider: () => getToken()),

    // Retry on failure
    RetryInterceptor(
      maxRetries: 3,
      retryableStatusCodes: [500, 502, 503, 504],
      exponentialBackoff: true,
    ),

    // Custom interceptor
    CustomInterceptor(
      onRequest: (req) => req.copyWith(
        headers: {...req.headers, 'X-Custom': 'value'},
      ),
    ),
  ],
);
```

### Annotations Reference

| Annotation | Usage | Example |
|------------|-------|---------|
| `@RestApi` | Define API class | `@RestApi(baseUrl: 'https://api.com')` |
| `@Get` | GET request | `@Get('/users')` |
| `@Post` | POST request | `@Post('/users')` |
| `@Put` | PUT request | `@Put('/users/{id}')` |
| `@Delete` | DELETE request | `@Delete('/users/{id}')` |
| `@Path` | Path parameter | `@Path() int id` |
| `@Query` | Query parameter | `@Query('page') int page` |
| `@Body` | Request body | `@Body() User user` |
| `@Header` | Header | `@Header('Authorization') String token` |

---

## 🧪 Testing with MockAdapter

```dart
import 'package:netrofit_all/netrofit_all.dart';

void main() {
  test('API returns users', () async {
    // Create mock adapter
    final mockAdapter = MockAdapter({
      '/users': MockResponse(
        body: '[{"id": 1, "name": "Test User", "email": "test@example.com"}]',
        statusCode: 200,
      ),
    });

    final api = UsersApi(httpAdapter: mockAdapter);
    final result = await api.getUsers();

    expect(result.isSuccess, true);
    expect(result.data!.length, 1);
    expect(result.data!.first.name, 'Test User');
  });

  test('API handles errors', () async {
    final mockAdapter = MockAdapter({
      '/users/999': MockResponse.error(
        message: 'User not found',
        statusCode: 404,
      ),
    });

    final api = UsersApi(httpAdapter: mockAdapter);
    final result = await api.getUser(999);

    expect(result.isFailure, true);
    expect(result.error!.statusCode, 404);
  });
}
```

---

## 📦 Demo App

Check out the `demo_app/` folder for a complete working example:

```bash
cd demo_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

The demo shows:
- ✅ REST Countries API integration
- ✅ List view with search
- ✅ Error handling
- ✅ Loading states
- ✅ Interceptors (logging)

---

## 🆚 Comparison with Other Packages

| Feature | Netrofit | Dio | Retrofit (Dart) | Chopper |
|---------|----------|-----|-----------------|---------|
| Type Safety | ✅ | ⚠️ | ✅ | ✅ |
| Code Generation | ✅ | ❌ | ✅ | ✅ |
| Result Type | ✅ | ❌ | ❌ | ❌ |
| Auto `part of` | ✅ | N/A | ❌ | ❌ |
| Mock Adapter | ✅ | ❌ | ❌ | ❌ |
| Single Package | ✅ | ✅ | ⚠️ | ⚠️ |
| Interceptors | ✅ | ✅ | ⚠️ | ✅ |
| SSL Pinning | ✅ | ✅ | ❌ | ❌ |

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

MIT License - see LICENSE file for details

---

## 🙏 Credits

Inspired by [Retrofit](https://square.github.io/retrofit/) (Java/Android) and [Dio](https://pub.dev/packages/dio).

---

**Made with ❤️ for the Flutter community**
