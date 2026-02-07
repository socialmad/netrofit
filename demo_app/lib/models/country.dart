import 'package:json_annotation/json_annotation.dart';

part 'country.g.dart';

@JsonSerializable()
class Country {
  final CountryName name;
  final List<String>? capital;
  final String region;
  final int population;
  final CountryFlags flags;
  final String cca2;

  const Country({
    required this.name,
    this.capital,
    required this.region,
    required this.population,
    required this.flags,
    required this.cca2,
  });

  factory Country.fromJson(Map<String, dynamic> json) =>
      _$CountryFromJson(json);
  Map<String, dynamic> toJson() => _$CountryToJson(this);
}

@JsonSerializable()
class CountryName {
  final String common;
  final String official;

  const CountryName({required this.common, required this.official});

  factory CountryName.fromJson(Map<String, dynamic> json) =>
      _$CountryNameFromJson(json);
  Map<String, dynamic> toJson() => _$CountryNameToJson(this);
}

@JsonSerializable()
class CountryFlags {
  final String png;
  final String svg;
  final String? alt;

  const CountryFlags({required this.png, required this.svg, this.alt});

  factory CountryFlags.fromJson(Map<String, dynamic> json) =>
      _$CountryFlagsFromJson(json);
  Map<String, dynamic> toJson() => _$CountryFlagsToJson(this);
}
