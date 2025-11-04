// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'electricity_rate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElectricityRate _$ElectricityRateFromJson(Map<String, dynamic> json) =>
    ElectricityRate(
      id: json['id'] as String,
      provider: json['provider'] as String,
      ratePerKwh: (json['ratePerKwh'] as num).toDouble(),
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      source: $enumDecode(_$RateSourceEnumMap, json['source']),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$ElectricityRateToJson(ElectricityRate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider': instance.provider,
      'ratePerKwh': instance.ratePerKwh,
      'effectiveDate': instance.effectiveDate.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'source': _$RateSourceEnumMap[instance.source]!,
      'userId': instance.userId,
    };

const _$RateSourceEnumMap = {
  RateSource.manual: 'manual',
  RateSource.facebook: 'facebook',
  RateSource.api: 'api',
};
