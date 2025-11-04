import 'package:json_annotation/json_annotation.dart';
import 'appliance_category.dart';

part 'appliance.g.dart';

@JsonSerializable()
class Appliance {
  final String id;
  final String name;
  final ApplianceCategory category;
  final int wattage;
  final String icon;
  final bool isBuiltIn;
  final DateTime createdAt;
  final String userId;
  final double hoursPerDay;

  const Appliance({
    required this.id,
    required this.name,
    required this.category,
    required this.wattage,
    required this.icon,
    this.isBuiltIn = false,
    required this.createdAt,
    required this.userId,
    this.hoursPerDay = 1.0,
  });

  factory Appliance.fromJson(Map<String, dynamic> json) =>
      _$ApplianceFromJson(json);

  Map<String, dynamic> toJson() => _$ApplianceToJson(this);

  Appliance copyWith({
    String? id,
    String? name,
    ApplianceCategory? category,
    int? wattage,
    String? icon,
    bool? isBuiltIn,
    DateTime? createdAt,
    String? userId,
    double? hoursPerDay,
  }) {
    return Appliance(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      wattage: wattage ?? this.wattage,
      icon: icon ?? this.icon,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
    );
  }

  factory Appliance.create({
    required String id,
    required String name,
    required ApplianceCategory category,
    required int wattage,
    required String userId,
    String? icon,
    bool isBuiltIn = false,
    double hoursPerDay = 1.0,
  }) {
    return Appliance(
      id: id,
      name: name,
      category: category,
      wattage: wattage,
      icon: icon ?? category.icon,
      isBuiltIn: isBuiltIn,
      createdAt: DateTime.now(),
      userId: userId,
      hoursPerDay: hoursPerDay,
    );
  }

  // Built-in appliances factory
  factory Appliance.builtIn({
    required String name,
    required ApplianceCategory category,
    required int wattage,
    double hoursPerDay = 1.0,
  }) {
    return Appliance(
      id: '${category.name}_${name.replaceAll(' ', '_').toLowerCase()}',
      name: name,
      category: category,
      wattage: wattage,
      icon: category.icon,
      isBuiltIn: true,
      createdAt: DateTime.now(),
      userId: 'system', // System-owned built-in appliances
      hoursPerDay: hoursPerDay,
    );
  }

  double calculateDailyCost(double ratePerKwh, double hoursPerDay) {
    // Formula: (wattage × hours / 1000) × rate
    return (wattage * hoursPerDay / 1000) * ratePerKwh;
  }

  double calculateMonthlyCost(double ratePerKwh, double hoursPerDay) {
    return calculateDailyCost(ratePerKwh, hoursPerDay) * 30;
  }

  double calculateWeeklyCost(double ratePerKwh, double hoursPerDay) {
    return calculateDailyCost(ratePerKwh, hoursPerDay) * 7;
  }

  bool get isValid =>
      id.isNotEmpty &&
      name.isNotEmpty &&
      wattage > 0 &&
      wattage <= 10000 && // Reasonable upper limit
      userId.isNotEmpty;

  @override
  String toString() {
    return 'Appliance(id: $id, name: $name, category: ${category.displayName}, wattage: ${wattage}W)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appliance && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
