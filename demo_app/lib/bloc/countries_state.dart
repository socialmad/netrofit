import 'package:equatable/equatable.dart';
import '../models/country.dart';

abstract class CountriesState extends Equatable {
  const CountriesState();

  @override
  List<Object?> get props => [];
}

class CountriesInitial extends CountriesState {}

class CountriesLoading extends CountriesState {}

class CountriesLoaded extends CountriesState {
  final List<Country> countries;
  final List<Country> filteredCountries;
  final String searchQuery;

  const CountriesLoaded({
    required this.countries,
    this.filteredCountries = const [],
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [countries, filteredCountries, searchQuery];

  CountriesLoaded copyWith({
    List<Country>? countries,
    List<Country>? filteredCountries,
    String? searchQuery,
  }) {
    return CountriesLoaded(
      countries: countries ?? this.countries,
      filteredCountries: filteredCountries ?? this.filteredCountries,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CountriesError extends CountriesState {
  final String message;

  const CountriesError(this.message);

  @override
  List<Object?> get props => [message];
}
