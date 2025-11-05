import 'package:json_annotation/json_annotation.dart';

part 'usage_record.g.dart';

@JsonSerializable()
class UsageRecord {
  final String id;
  final String applianceId;
  final DateTime date;
  final double hoursUsed;
  final double cost;
  final String userId;
  final String? notes;

  const UsageRecord({
    required this.id,
    required this.applianceId,
    required this.date,
    required this.hoursUsed,
    required this.cost,
    required this.userId,
    this.notes,
  });

  factory UsageRecord.fromJson(Map<String, dynamic> json) =>
      _$UsageRecordFromJson(json);

  Map<String, dynamic> toJson() => _$UsageRecordToJson(this);

  UsageRecord copyWith({
    String? id,
    String? applianceId,
    DateTime? date,
    double? hoursUsed,
    double? cost,
    String? userId,
    String? notes,
  }) {
    return UsageRecord(
      id: id ?? this.id,
      applianceId: applianceId ?? this.applianceId,
      date: date ?? this.date,
      hoursUsed: hoursUsed ?? this.hoursUsed,
      cost: cost ?? this.cost,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
    );
  }

  factory UsageRecord.create({
    required String id,
    required String applianceId,
    required DateTime date,
    required double hoursUsed,
    required double cost,
    required String userId,
    String? notes,
  }) {
    return UsageRecord(
      id: id,
      applianceId: applianceId,
      date: date,
      hoursUsed: hoursUsed,
      cost: cost,
      userId: userId,
      notes: notes,
    );
  }

  factory UsageRecord.calculate({
    required String id,
    required String applianceId,
    required DateTime date,
    required double hoursUsed,
    required int wattage,
    required double ratePerKwh,
    required String userId,
    String? notes,
  }) {
    // Calculate cost: (wattage × hours / 1000) × rate
    final cost = (wattage * hoursUsed / 1000) * ratePerKwh;

    return UsageRecord(
      id: id,
      applianceId: applianceId,
      date: date,
      hoursUsed: hoursUsed,
      cost: cost,
      userId: userId,
      notes: notes,
    );
  }

  bool get isValid =>
      id.isNotEmpty &&
      applianceId.isNotEmpty &&
      hoursUsed >= 0 &&
      hoursUsed <= 24 && // Max 24 hours per day
      cost >= 0 &&
      userId.isNotEmpty;

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  String get formattedCost => 'PHP ${cost.toStringAsFixed(2)}';

  String get formattedHours => '${hoursUsed.toStringAsFixed(1)}h';

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  bool isSameDate(DateTime other) {
    return dateOnly == DateTime(other.year, other.month, other.day);
  }

  @override
  String toString() {
    return 'UsageRecord(id: $id, applianceId: $applianceId, date: $date, hours: $hoursUsed, cost: PHP ${cost.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UsageRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
