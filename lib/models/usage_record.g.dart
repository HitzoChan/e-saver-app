// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsageRecord _$UsageRecordFromJson(Map<String, dynamic> json) => UsageRecord(
  id: json['id'] as String,
  applianceId: json['applianceId'] as String,
  date: DateTime.parse(json['date'] as String),
  hoursUsed: (json['hoursUsed'] as num).toDouble(),
  cost: (json['cost'] as num).toDouble(),
  userId: json['userId'] as String,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$UsageRecordToJson(UsageRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'applianceId': instance.applianceId,
      'date': instance.date.toIso8601String(),
      'hoursUsed': instance.hoursUsed,
      'cost': instance.cost,
      'userId': instance.userId,
      'notes': instance.notes,
    };
