// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
  id: json['id'] as String,
  monthlyGoal: (json['monthlyGoal'] as num).toDouble(),
  currentUsage: (json['currentUsage'] as num).toDouble(),
  alertThreshold: (json['alertThreshold'] as num?)?.toDouble() ?? 0.8,
  alertsEnabled: json['alertsEnabled'] as bool? ?? true,
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  userId: json['userId'] as String,
);

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
  'id': instance.id,
  'monthlyGoal': instance.monthlyGoal,
  'currentUsage': instance.currentUsage,
  'alertThreshold': instance.alertThreshold,
  'alertsEnabled': instance.alertsEnabled,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'userId': instance.userId,
};
