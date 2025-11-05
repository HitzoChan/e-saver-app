import 'notification_service.dart';

class PlannerNotificationService {
  final NotificationService _notificationService = NotificationService();

  /// Send a planner tip notification
  Future<void> sendPlannerTip({
    required String title,
    required String body,
  }) async {
    await _notificationService.showPlannerTipNotification(
      title: title,
      body: body,
    );
  }

  /// Send consumption alert notification
  Future<void> sendConsumptionAlert({
    required String title,
    required String body,
  }) async {
    await _notificationService.showConsumptionAlertNotification(
      title: title,
      body: body,
    );
  }

  /// Send budget reminder notification
  Future<void> sendBudgetReminder({
    required String title,
    required String body,
  }) async {
    await _notificationService.showPlannerTipNotification(
      title: title,
      body: body,
    );
  }

  /// Send energy saving tip notification
  Future<void> sendEnergySavingTip({
    required String title,
    required String body,
  }) async {
    await _notificationService.showEnergyTipNotification(
      title: title,
      body: body,
    );
  }

  /// Predefined planner tips that can be sent randomly or based on usage patterns
  final List<Map<String, String>> _plannerTips = [
    {
      'title': '💡 Smart Appliance Usage',
      'body': 'Unplug appliances when not in use. Standby mode still consumes 10-15% of normal power!'
    },
    {
      'title': '🌡️ Temperature Control',
      'body': 'Set your air conditioner to 25°C. Every degree lower increases energy use by 10%.'
    },
    {
      'title': '💰 Budget Check',
      'body': 'You\'re approaching 80% of your monthly electricity budget. Consider reducing usage this week.'
    },
    {
      'title': '🔌 Power Strip Solution',
      'body': 'Use power strips with switches to easily turn off multiple devices at once.'
    },
    {
      'title': '☀️ Natural Light',
      'body': 'Maximize natural daylight during the day to reduce artificial lighting needs.'
    },
    {
      'title': '🧊 Refrigerator Tips',
      'body': 'Keep your refrigerator at 4°C and freezer at -18°C for optimal energy efficiency.'
    },
    {
      'title': '💻 Computer Power',
      'body': 'Enable sleep mode on your computer after 10 minutes of inactivity.'
    },
    {
      'title': '🏠 Home Audit',
      'body': 'Check for air leaks around windows and doors. Seal them to reduce heating/cooling costs.'
    },
  ];

  /// Get a random planner tip
  Map<String, String> getRandomTip() {
    final random = DateTime.now().millisecondsSinceEpoch % _plannerTips.length;
    return _plannerTips[random];
  }

  /// Send a random planner tip notification
  Future<void> sendRandomPlannerTip() async {
    final tip = getRandomTip();
    await sendPlannerTip(
      title: tip['title']!,
      body: tip['body']!,
    );
  }

  /// Send consumption alert based on budget threshold
  Future<void> sendBudgetThresholdAlert({
    required double currentUsage,
    required double budgetLimit,
    required double threshold, // e.g., 0.8 for 80%
  }) async {
    final usagePercentage = currentUsage / budgetLimit;
    if (usagePercentage >= threshold) {
      final percentage = (usagePercentage * 100).round();
      await sendConsumptionAlert(
        title: '⚠️ Budget Alert',
        body: 'You\'ve used $percentage% of your monthly electricity budget. Current: PHP ${currentUsage.toStringAsFixed(2)}',
      );
    }
  }

  /// Send weekly usage summary
  Future<void> sendWeeklyUsageSummary({
    required double weeklyUsage,
    required double weeklyBudget,
    required int daysTracked,
  }) async {
    final isOverBudget = weeklyUsage > weeklyBudget;
    final status = isOverBudget ? 'over budget' : 'within budget';
    final difference = (weeklyUsage - weeklyBudget).abs();

    await sendPlannerTip(
      title: '📊 Weekly Usage Summary',
      body: 'PHP ${weeklyUsage.toStringAsFixed(2)} used this week ($daysTracked days) - $status by PHP ${difference.toStringAsFixed(2)}',
    );
  }
}
