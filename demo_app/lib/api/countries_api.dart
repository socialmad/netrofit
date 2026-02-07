import 'dart:convert';

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

  @Get('/region/{region}?fields=$_fields')
  Future<ApiResult<List<Country>>> getByRegion(@Path() String region);
}
