import 'package:json_annotation/json_annotation.dart';
import 'rate_source.dart';

part 'electricity_rate.g.dart';

@JsonSerializable()
class ElectricityRate {
  final String id;
  final String provider;
  final double ratePerKwh;
  final DateTime effectiveDate;
  final DateTime lastUpdated;
  final RateSource source;
  final String userId;

  const ElectricityRate({
    required this.id,
    required this.provider,
    required this.ratePerKwh,
    required this.effectiveDate,
    required this.lastUpdated,
    required this.source,
    required this.userId,
  });

  factory ElectricityRate.fromJson(Map<String, dynamic> json) =>
      _$ElectricityRateFromJson(json);

  Map<String, dynamic> toJson() => _$ElectricityRateToJson(this);

  ElectricityRate copyWith({
    String? id,
    String? provider,
    double? ratePerKwh,
    DateTime? effectiveDate,
    DateTime? lastUpdated,
    RateSource? source,
    String? userId,
  }) {
    return ElectricityRate(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      ratePerKwh: ratePerKwh ?? this.ratePerKwh,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      source: source ?? this.source,
      userId: userId ?? this.userId,
    );
  }

  factory ElectricityRate.manual({
    required String id,
    required String provider,
    required double ratePerKwh,
    required String userId,
  }) {
    final now = DateTime.now();
    return ElectricityRate(
      id: id,
      provider: provider,
      ratePerKwh: ratePerKwh,
      effectiveDate: now,
      lastUpdated: now,
      source: RateSource.manual,
      userId: userId,
    );
  }

  factory ElectricityRate.fromFacebook({
    required String id,
    required String provider,
    required double ratePerKwh,
    required DateTime effectiveDate,
    required String userId,
  }) {
    return ElectricityRate(
      id: id,
      provider: provider,
      ratePerKwh: ratePerKwh,
      effectiveDate: effectiveDate,
      lastUpdated: DateTime.now(),
      source: RateSource.facebook,
      userId: userId,
    );
  }

  bool isCurrent() {
    final now = DateTime.now();
    return effectiveDate.isBefore(now) || effectiveDate.isAtSameMomentAs(now);
  }

  bool isExpired() {
    // Consider rate expired if it's more than 30 days old
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return lastUpdated.isBefore(thirtyDaysAgo);
  }

  Duration get age => DateTime.now().difference(effectiveDate);

  String get ageDescription {
    final days = age.inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).round()} weeks ago';
    return '${(days / 30).round()} months ago';
  }

  bool get isValid =>
      id.isNotEmpty &&
      provider.isNotEmpty &&
      ratePerKwh > 0 &&
      ratePerKwh <= 100 && // Reasonable upper limit for PHP/kWh
      userId.isNotEmpty;

  @override
  String toString() {
    return 'ElectricityRate(provider: $provider, rate: PHP ${ratePerKwh.toStringAsFixed(2)}/kWh, source: ${source.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElectricityRate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
