import 'package:netrofit_all/netrofit_all.dart';
import '../api/countries_api.dart';

class CountriesService {
  static final CountriesService _instance = CountriesService._internal();

  late final CountriesApi _api;

  factory CountriesService() {
    return _instance;
  }

  CountriesService._internal() {
    final httpAdapter = HttpPackageAdapter(
      interceptors: [LoggingInterceptor(level: LogLevel.basic)],
    );
    _api = CountriesApi(httpAdapter: httpAdapter);
  }

  CountriesApi get api => _api;
}
