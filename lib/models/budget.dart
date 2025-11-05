import 'package:json_annotation/json_annotation.dart';

part 'budget.g.dart';

@JsonSerializable()
class Budget {
  final String id;
  final double monthlyGoal;
  final double currentUsage;
  final double alertThreshold;
  final bool alertsEnabled;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String userId;

  const Budget({
    required this.id,
    required this.monthlyGoal,
    required this.currentUsage,
    this.alertThreshold = 0.8, // 80% default
    this.alertsEnabled = true,
    required this.periodStart,
    required this.periodEnd,
    required this.userId,
  });

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetToJson(this);

  Budget copyWith({
    String? id,
    double? monthlyGoal,
    double? currentUsage,
    double? alertThreshold,
    bool? alertsEnabled,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? userId,
  }) {
    return Budget(
      id: id ?? this.id,
      monthlyGoal: monthlyGoal ?? this.monthlyGoal,
      currentUsage: currentUsage ?? this.currentUsage,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      userId: userId ?? this.userId,
    );
  }

  factory Budget.defaultBudget({
    required String id,
    required double monthlyGoal,
    required String userId,
  }) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return Budget(
      id: id,
      monthlyGoal: monthlyGoal,
      currentUsage: 0.0,
      alertThreshold: 0.8,
      alertsEnabled: true,
      periodStart: startOfMonth,
      periodEnd: endOfMonth,
      userId: userId,
    );
  }

  factory Budget.create({
    required String id,
    required double monthlyGoal,
    required String userId,
    double alertThreshold = 0.8,
    bool alertsEnabled = true,
  }) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return Budget(
      id: id,
      monthlyGoal: monthlyGoal,
      currentUsage: 0.0,
      alertThreshold: alertThreshold,
      alertsEnabled: alertsEnabled,
      periodStart: startOfMonth,
      periodEnd: endOfMonth,
      userId: userId,
    );
  }

  double get remainingAmount => monthlyGoal - currentUsage;

  double get progressPercentage => currentUsage / monthlyGoal;

  bool get isOverBudget => currentUsage > monthlyGoal;

  bool get shouldAlert =>
      alertsEnabled &&
      currentUsage >= (monthlyGoal * alertThreshold) &&
      !isOverBudget;

  bool get isNearLimit =>
      alertsEnabled &&
      progressPercentage >= alertThreshold &&
      progressPercentage < 1.0;

  bool get isCurrentPeriod {
    final now = DateTime.now();
    return now.isAfter(periodStart) && now.isBefore(periodEnd);
  }

  int get daysRemaining {
    final now = DateTime.now();
    return periodEnd.difference(now).inDays;
  }

  double get dailyBudget => remainingAmount / daysRemaining;

  String get formattedGoal => 'PHP ${monthlyGoal.toStringAsFixed(0)}';

  String get formattedCurrent => 'PHP ${currentUsage.toStringAsFixed(2)}';

  String get formattedRemaining => 'PHP ${remainingAmount.toStringAsFixed(2)}';

  String get progressText => '${(progressPercentage * 100).toStringAsFixed(1)}%';

  Budget updateUsage(double newUsage) {
    return copyWith(currentUsage: newUsage);
  }

  Budget addToUsage(double amount) {
    return copyWith(currentUsage: currentUsage + amount);
  }

  bool get isValid =>
      id.isNotEmpty &&
      monthlyGoal > 0 &&
      currentUsage >= 0 &&
      alertThreshold > 0 &&
      alertThreshold <= 1 &&
      periodStart.isBefore(periodEnd) &&
      userId.isNotEmpty;

  @override
  String toString() {
    return 'Budget(id: $id, goal: PHP ${monthlyGoal.toStringAsFixed(0)}, current: PHP ${currentUsage.toStringAsFixed(2)}, progress: ${(progressPercentage * 100).toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
