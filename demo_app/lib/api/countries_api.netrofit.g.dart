// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'countries_api.dart';

// **************************************************************************
// RestApiGenerator
// **************************************************************************

// **************************************************************************
// RestApiGenerator
// **************************************************************************

class _$CountriesApiImpl implements CountriesApi {
  _$CountriesApiImpl({required HttpAdapter httpAdapter})
      : _httpAdapter = httpAdapter;

  final HttpAdapter _httpAdapter;

  Future<ApiResult<List<Country>>> getAllCountries() async {
    final url =
        'https://restcountries.com/v3.1/all?fields=name,capital,region,population,flags,cca2';
    final headers = <String, String>{};
    final queryParams = <String, dynamic>{};
    final options = RequestOptions(
      method: 'GET',
      url: url,
      headers: headers,
      queryParameters: queryParams,
    );
    try {
      final response = await _httpAdapter.get(options);

      if (response.isSuccessful) {
        final decoded = jsonDecode(response.body) as List;
        final data = decoded
            .map((e) => Country.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResult.success(
          data: data,
          statusCode: response.statusCode,
          headers: response.headers,
        );
      } else {
        return ApiResult.failure(
          error: ServerError('Request failed', statusCode: response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on ApiError catch (e) {
      return ApiResult.failure(error: e);
    } catch (e, stackTrace) {
      return ApiResult.failure(
        error:
            UnknownError('Unknown error: $e', cause: e, stackTrace: stackTrace),
      );
    }
  }

  Future<ApiResult<List<Country>>> searchByName(String name) async {
    var path = '/name/{name}?fields=name,capital,region,population,flags,cca2';
    path = path.replaceAll('{name}', name.toString());
    final url = 'https://restcountries.com/v3.1' + path;
    final headers = <String, String>{};
    final queryParams = <String, dynamic>{};
    final options = RequestOptions(
      method: 'GET',
      url: url,
      headers: headers,
      queryParameters: queryParams,
    );
    try {
      final response = await _httpAdapter.get(options);

      if (response.isSuccessful) {
        final decoded = jsonDecode(response.body) as List;
        final data = decoded
            .map((e) => Country.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResult.success(
          data: data,
          statusCode: response.statusCode,
          headers: response.headers,
        );
      } else {
        return ApiResult.failure(
          error: ServerError('Request failed', statusCode: response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on ApiError catch (e) {
      return ApiResult.failure(error: e);
    } catch (e, stackTrace) {
      return ApiResult.failure(
        error:
            UnknownError('Unknown error: $e', cause: e, stackTrace: stackTrace),
      );
    }
  }

  Future<ApiResult<List<Country>>> getByRegion(String region) async {
    var path =
        '/region/{region}?fields=name,capital,region,population,flags,cca2';
    path = path.replaceAll('{region}', region.toString());
    final url = 'https://restcountries.com/v3.1' + path;
    final headers = <String, String>{};
    final queryParams = <String, dynamic>{};
    final options = RequestOptions(
      method: 'GET',
      url: url,
      headers: headers,
      queryParameters: queryParams,
    );
    try {
      final response = await _httpAdapter.get(options);

      if (response.isSuccessful) {
        final decoded = jsonDecode(response.body) as List;
        final data = decoded
            .map((e) => Country.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResult.success(
          data: data,
          statusCode: response.statusCode,
          headers: response.headers,
        );
      } else {
        return ApiResult.failure(
          error: ServerError('Request failed', statusCode: response.statusCode),
          statusCode: response.statusCode,
        );
      }
    } on ApiError catch (e) {
      return ApiResult.failure(error: e);
    } catch (e, stackTrace) {
      return ApiResult.failure(
        error:
            UnknownError('Unknown error: $e', cause: e, stackTrace: stackTrace),
      );
    }
  }
}
