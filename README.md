# Netrofit

> [!IMPORTANT]
> **🚧 Work in Progress - Call for Community Feedback 🚧**
>
> **Netrofit** is currently in active development and **not yet published on pub.dev**.
>
> We are sharing it early to gather feedback from the Flutter community.
> - 📢 **We want your input!** Please open an issue to suggest features, report bugs, or discuss the API design.
> - ⚠️ **Breaking changes** may occur as we refine the library based on your feedback.
> - 📦 **Installation**: See the updated [Quick Start](#-quick-start) guide to use the Git dependency.

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
  # Netrofit (Git dependency)
  netrofit_all:
    git:
      url: https://github.com/user/netrofit.git
      path: packages/netrofit_all
      ref: main
  
  json_annotation: ^4.9.0      # For JSON serialization

dev_dependencies:
  # Code generator (Git dependency)
  netrofit_generator:
    git:
      url: https://github.com/user/netrofit.git
      path: packages/netrofit_generator
      ref: main

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
// lib/api/countries_api.dart
import 'package:netrofit_all/netrofit_all.dart';
import '../models/country.dart';

part 'countries_api.netrofit.g.dart';

@RestApi(baseUrl: 'https://restcountries.com/v3.1')
abstract class CountriesApi {
  factory CountriesApi({required HttpAdapter httpAdapter}) = _$CountriesApiImpl;

  static const _fields = 'name,capital,region,population,flags,cca2';

  @Get('/all?fields=$_fields')
  Future<ApiResult<List<Country>>> getAllCountries();

  @Get('/name/{name}?fields=$_fields')
  Future<ApiResult<List<Country>>> searchByName(@Path() String name);
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
mv lib/api/countries_api.netrofit.g.part lib/api/countries_api.netrofit.g.dart
```

> **Note**: The generator creates a `.part` file that needs to be renamed to `.g.dart`. This is a known limitation we're working to fix.

### Use Your API

```dart
// Initialize the API
final httpAdapter = HttpPackageAdapter(
  interceptors: [LoggingInterceptor(level: LogLevel.basic)],
);
final api = CountriesApi(httpAdapter: httpAdapter);

// Make API calls
final result = await api.getAllCountries();

// Handle the result
result.when(
  success: (countries) {
    print('Got ${countries.length} countries');
    for (var country in countries) {
      print('- ${country.name.common} (${country.region})');
    }
  },
  failure: (error) => print('Error: ${error.message}'),
);
```

**That's it!** 🎉 No manual HTTP code, no JSON parsing, no error handling boilerplate.

---

## 📖 Step-by-Step Guide

### Step 1: Create Your Model

```dart
// lib/models/country.dart
import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  final CountryName name;
  final String region;
  final CountryFlags flags;

  const Country({
    required this.name,
    required this.region,
    required this.flags,
  });

  factory Country.fromJson(Map<String, dynamic> json) => _$CountryFromJson(json);
  Map<String, dynamic> toJson() => _$CountryToJson(this);
}

@JsonSerializable()
class CountryName {
  final String common;
  const CountryName({required this.common});
  factory CountryName.fromJson(Map<String, dynamic> json) => _$CountryNameFromJson(json);
  Map<String, dynamic> toJson() => _$CountryNameToJson(this);
}

@JsonSerializable()
class CountryFlags {
  final String png;
  const CountryFlags({required this.png});
  factory CountryFlags.fromJson(Map<String, dynamic> json) => _$CountryFlagsFromJson(json);
  Map<String, dynamic> toJson() => _$CountryFlagsToJson(this);
}
```

### Step 2: Define API Endpoints

```dart
// lib/api/countries_api.dart
import 'package:netrofit_all/netrofit_all.dart';
import '../models/country.dart';

part 'countries_api.netrofit.g.dart';

@RestApi(baseUrl: 'https://restcountries.com/v3.1')
abstract class CountriesApi {
  factory CountriesApi({required HttpAdapter httpAdapter}) = _$CountriesApiImpl;

  // Constants for query parameters
  static const _fields = 'name,capital,region,population,flags,cca2';

  // GET request with query parameter
  @Get('/all?fields=$_fields')
  Future<ApiResult<List<Country>>> getAllCountries();

  // GET with path parameter
  @Get('/name/{name}?fields=$_fields')
  Future<ApiResult<List<Country>>> searchByName(@Path() String name);

  // GET with path parameter
  @Get('/region/{region}?fields=$_fields')
  Future<ApiResult<List<Country>>> getByRegion(@Path() String region);
}
```

### Step 3: Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates `countries_api.netrofit.g.dart` and `country.g.dart` automatically!

### Step 4: Initialize and Use

```dart
// lib/services/countries_service.dart
import 'package:netrofit_all/netrofit_all.dart';
import '../api/countries_api.dart';

class CountriesService {
  late final CountriesApi api;

  CountriesService() {
    final httpAdapter = HttpPackageAdapter(
      interceptors: [
        LoggingInterceptor(level: LogLevel.basic),
        RetryInterceptor(maxRetries: 3),
      ],
    );
    api = CountriesApi(httpAdapter: httpAdapter);
  }
}

// Usage in your app (e.g., in a Cubit/Bloc)
void loadCountries() async {
  final service = CountriesService();
  
  // Make API call
  final result = await service.api.getAllCountries();

  // Handle result
  result.when(
    success: (countries) {
      print('Success! Got ${countries.length} countries');
      for (var country in countries) {
        print('- ${country.name.common} (${country.region})');
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
final countries = result.dataOrNull;  // Returns List<Country> or null
final error = result.errorOrNull;  // Returns error or null

try {
  final countries = result.unwrap();  // Throws on error
  print(countries.first.name.common);
} catch (e) {
  print('Failed: $e');
}

// Chain API calls (e.g., search then filter by region)
final result = await api.searchByName('United')
    .then((r) => r.flatMap((countries) {
        // This is a contrived example for chaining
        final first = countries.first;
        return api.getByRegion(first.region);
    }));

// Async chaining
final result = await api.searchByName('United')
    .then((r) => r.thenAsync((countries) async {
       return await api.getByRegion(countries.first.region);
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
  test('API returns countries', () async {
    // Create mock adapter
    final mockAdapter = MockAdapter({
      '/all': MockResponse(
        body: '[{"name": {"common": "United Kingdoms"}, "region": "Europe", "flags": {"png": "url"}}]',
        statusCode: 200,
      ),
    });

    final api = CountriesApi(httpAdapter: mockAdapter);
    final result = await api.getAllCountries();

    expect(result.isSuccess, true);
    expect(result.data!.length, 1);
    expect(result.data!.first.name.common, 'United Kingdoms');
  });

  test('API handles errors', () async {
    final mockAdapter = MockAdapter({
      '/name/Invalid': MockResponse.error(
        message: 'Not found',
        statusCode: 404,
      ),
    });

    final api = CountriesApi(httpAdapter: mockAdapter);
    final result = await api.searchByName('Invalid');

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
