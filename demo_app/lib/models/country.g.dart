// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Country _$CountryFromJson(Map<String, dynamic> json) => Country(
      name: CountryName.fromJson(json['name'] as Map<String, dynamic>),
      capital:
          (json['capital'] as List<dynamic>?)?.map((e) => e as String).toList(),
      region: json['region'] as String,
      population: (json['population'] as num).toInt(),
      flags: CountryFlags.fromJson(json['flags'] as Map<String, dynamic>),
      cca2: json['cca2'] as String,
    );

Map<String, dynamic> _$CountryToJson(Country instance) => <String, dynamic>{
      'name': instance.name,
      'capital': instance.capital,
      'region': instance.region,
      'population': instance.population,
      'flags': instance.flags,
      'cca2': instance.cca2,
    };

CountryName _$CountryNameFromJson(Map<String, dynamic> json) => CountryName(
      common: json['common'] as String,
      official: json['official'] as String,
    );

Map<String, dynamic> _$CountryNameToJson(CountryName instance) =>
    <String, dynamic>{
      'common': instance.common,
      'official': instance.official,
    };

CountryFlags _$CountryFlagsFromJson(Map<String, dynamic> json) => CountryFlags(
      png: json['png'] as String,
      svg: json['svg'] as String,
      alt: json['alt'] as String?,
    );

Map<String, dynamic> _$CountryFlagsToJson(CountryFlags instance) =>
    <String, dynamic>{
      'png': instance.png,
      'svg': instance.svg,
      'alt': instance.alt,
    };
