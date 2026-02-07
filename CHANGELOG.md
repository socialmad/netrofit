# Changelog

All notable changes to the Netrofit package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-02-07

### Added

- **netrofit_core**: Base HTTP adapter interface, `RequestOptions`, `RawResponse`, `ApiConfig`, `CancelToken`, interceptors contract.
- **netrofit_annotations**: `@RestApi`, `@Get`, `@Post`, `@Put`, `@Delete`, `@Patch`, `@Head`, `@Body`, `@Path`, `@Query`, `@Header`, `@Headers`, `@Field`, `@FormUrlEncoded`, `@Multipart`, `@Part`, `@Cache`, `@Retry`, `@Timeout`, `@Extra`.
- **netrofit_http**: `HttpPackageAdapter` using `package:http`, SSL config, `LoggingInterceptor`, `AuthInterceptor`, `RetryInterceptor`, `CacheInterceptor`.
- **netrofit_result**: `ApiResult<T>`, `ApiError` hierarchy (`NetworkError`, `ServerError`, `ClientError`, `TimeoutError`, `CancellationError`, `SslError`, `ParseError`, `UnknownError`).
- **netrofit_generator**: Build_runner generator for `@RestApi` – path/query/body/headers, typed response parsing (`User.fromJson`, `List<User>`), path parameter substitution.
- **netrofit_cli**: CLI to generate Dart models from JSON (`dart run netrofit_cli:generate_model`).
- **netrofit_all**: Umbrella package re-exporting core, annotations, http, and result.

### Notes

- Multipart upload annotations exist but are not yet implemented in the generator.
- API library must `import 'dart:convert';` for generated code.
