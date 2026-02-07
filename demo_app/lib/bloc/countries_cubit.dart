import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/countries_service.dart';
import 'countries_state.dart';

class CountriesCubit extends Cubit<CountriesState> {
  final CountriesService _service;

  CountriesCubit({CountriesService? service})
    : _service = service ?? CountriesService(),
      super(CountriesInitial());

  Future<void> loadCountries() async {
    emit(CountriesLoading());

    final result = await _service.api.getAllCountries();

    result.when(
      success: (countries) {
        emit(
          CountriesLoaded(countries: countries, filteredCountries: countries),
        );
      },
      failure: (error) {
        emit(CountriesError(error.message));
      },
    );
  }

  void searchCountries(String query) {
    if (state is CountriesLoaded) {
      final currentState = state as CountriesLoaded;

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredCountries: currentState.countries,
            searchQuery: query,
          ),
        );
        return;
      }

      final lowercaseQuery = query.toLowerCase();
      final filtered = currentState.countries.where((country) {
        return country.name.common.toLowerCase().contains(lowercaseQuery) ||
            country.region.toLowerCase().contains(lowercaseQuery) ||
            (country.capital?.any(
                  (c) => c.toLowerCase().contains(lowercaseQuery),
                ) ??
                false);
      }).toList();

      emit(
        currentState.copyWith(filteredCountries: filtered, searchQuery: query),
      );
    }
  }
}
