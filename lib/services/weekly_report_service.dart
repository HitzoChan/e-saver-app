import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class WeeklyReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<void> generateAndSendWeeklyReport(String userId) async {
    try {
      // Get user's appliances and usage data for the past week
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));

      final usageQuery = await _firestore
          .collection('usage_records')
          .where('user_id', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .get();

      if (usageQuery.docs.isEmpty) {
        // Send notification about no usage data
        await _notificationService.showWeeklyReportNotification(
          title: 'Weekly Energy Report',
          body: 'No energy usage recorded this week. Start tracking to see your savings!',
        );
        return;
      }

      // Calculate weekly statistics
      double totalCost = 0;
      double totalKwh = 0;
      int daysTracked = 0;

      final dailyCosts = <DateTime, double>{};

      for (final doc in usageQuery.docs) {
        final data = doc.data();
        final cost = (data['cost_per_day'] as num?)?.toDouble() ?? 0;
        final kwh = (data['kwh_per_day'] as num?)?.toDouble() ?? 0;
        final date = (data['date'] as Timestamp).toDate();

        totalCost += cost;
        totalKwh += kwh;

        final dayKey = DateTime(date.year, date.month, date.day);
        dailyCosts[dayKey] = (dailyCosts[dayKey] ?? 0) + cost;

        if (!dailyCosts.containsKey(dayKey)) {
          daysTracked++;
        }
      }

      // Calculate averages
      final avgDailyCost = daysTracked > 0 ? totalCost / daysTracked : 0.0;
      final avgDailyKwh = daysTracked > 0 ? totalKwh / daysTracked : 0.0;

      // Get user's budget if set
      final budgetQuery = await _firestore
          .collection('budgets')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      double? monthlyBudget;
      if (budgetQuery.docs.isNotEmpty) {
        final limit = budgetQuery.docs.first.data()['monthly_limit'];
        if (limit is num) {
          monthlyBudget = limit.toDouble();
        }
      }

      // Generate report message
      final reportMessage = _generateReportMessage(
        totalCost: totalCost,
        totalKwh: totalKwh,
        avgDailyCost: avgDailyCost,
        avgDailyKwh: avgDailyKwh,
        daysTracked: daysTracked,
        monthlyBudget: monthlyBudget,
      );

      await _notificationService.showWeeklyReportNotification(
        title: 'Weekly Energy Report',
        body: reportMessage,
      );

    } catch (e) {
      // Log error in development, handle gracefully in production
      // TODO: Replace with proper logging framework
      developer.log('Error generating weekly report: $e', name: 'WeeklyReportService');
    }
  }

  String _generateReportMessage({
    required double totalCost,
    required double totalKwh,
    required double avgDailyCost,
    required double avgDailyKwh,
    required int daysTracked,
    required double? monthlyBudget,
  }) {
    final buffer = StringBuffer();

    buffer.write('PHP ${totalCost.toStringAsFixed(2)} spent on ${totalKwh.toStringAsFixed(1)} kWh');

    if (daysTracked > 0) {
      buffer.write(' over $daysTracked days.');
      buffer.write(' Avg: PHP ${avgDailyCost.toStringAsFixed(2)}/day');
    }

    if (monthlyBudget != null) {
      final weeklyBudget = monthlyBudget / 4.33; // Approximate weeks per month
      if (totalCost > weeklyBudget) {
        buffer.write(' (Over budget by PHP ${(totalCost - weeklyBudget).toStringAsFixed(2)})');
      } else {
        buffer.write(' (PHP ${(weeklyBudget - totalCost).toStringAsFixed(2)} under budget)');
      }
    }

    return buffer.toString();
  }

  // Schedule weekly reports (this would typically be handled by a background service)
  Future<void> scheduleWeeklyReports(String userId) async {
    // This is a simplified version. In production, you'd use a proper scheduling service
    // like WorkManager (Android) or BGTaskScheduler (iOS)

    final now = DateTime.now();
    final nextReportTime = _getNextSunday(now);

    // For demo purposes, we'll just store when the next report should be sent
    await _firestore.collection('scheduled_reports').doc(userId).set({
      'user_id': userId,
      'next_report_date': Timestamp.fromDate(nextReportTime),
      'is_active': true,
    });
  }

  DateTime _getNextSunday(DateTime from) {
    final daysUntilSunday = (7 - from.weekday) % 7;
    return DateTime(
      from.year,
      from.month,
      from.day + (daysUntilSunday == 0 ? 7 : daysUntilSunday),
      9, // 9 AM
      0,
    );
  }
}
