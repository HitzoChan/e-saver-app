// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appliance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Appliance _$ApplianceFromJson(Map<String, dynamic> json) => Appliance(
  id: json['id'] as String,
  name: json['name'] as String,
  category: $enumDecode(_$ApplianceCategoryEnumMap, json['category']),
  wattage: (json['wattage'] as num).toInt(),
  icon: json['icon'] as String,
  isBuiltIn: json['isBuiltIn'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  userId: json['userId'] as String,
  hoursPerDay: (json['hoursPerDay'] as num?)?.toDouble() ?? 1.0,
);

Map<String, dynamic> _$ApplianceToJson(Appliance instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': _$ApplianceCategoryEnumMap[instance.category]!,
  'wattage': instance.wattage,
  'icon': instance.icon,
  'isBuiltIn': instance.isBuiltIn,
  'createdAt': instance.createdAt.toIso8601String(),
  'userId': instance.userId,
  'hoursPerDay': instance.hoursPerDay,
};

const _$ApplianceCategoryEnumMap = {
  ApplianceCategory.kitchen: 'kitchen',
  ApplianceCategory.cooling: 'cooling',
  ApplianceCategory.laundry: 'laundry',
  ApplianceCategory.entertainment: 'entertainment',
  ApplianceCategory.electronics: 'electronics',
  ApplianceCategory.cleaning: 'cleaning',
  ApplianceCategory.personalCare: 'personalCare',
  ApplianceCategory.lighting: 'lighting',
  ApplianceCategory.business: 'business',
  ApplianceCategory.dorm: 'dorm',
  ApplianceCategory.essentials: 'essentials',
  ApplianceCategory.other: 'other',
};
