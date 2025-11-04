import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';
import '../services/appliance_service.dart';
import '../services/electricity_rate_service.dart';
import '../services/planner_notification_service.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  final ApplianceService _applianceService = ApplianceService();
  final ElectricityRateService _rateService = ElectricityRateService();
  final PlannerNotificationService _plannerNotificationService = PlannerNotificationService();

  Budget? _currentBudget;
  bool _isLoading = true;
  String? _error;

  Budget? get currentBudget => _currentBudget;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculated values
  bool get hasActiveBudget => _currentBudget != null;
  double get progressPercentage => _currentBudget?.progressPercentage ?? 0.0;
  double get remainingAmount => _currentBudget?.remainingAmount ?? 0.0;
  int get daysRemaining => _currentBudget?.daysRemaining ?? 0;
  double get dailyBudget => _currentBudget?.dailyBudget ?? 0.0;
  bool get isOverBudget => _currentBudget?.isOverBudget ?? false;
  bool get shouldAlert => _currentBudget?.shouldAlert ?? false;
  bool get isNearLimit => _currentBudget?.isNearLimit ?? false;

  Future<void> loadCurrentBudget() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentBudget = await _budgetService.getCurrentBudget();

      // If no current budget, try to calculate current usage
      if (_currentBudget == null) {
        await _createDefaultBudgetIfNeeded();
      } else {
        // Update current usage based on appliances
        await _updateCurrentUsage();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createDefaultBudgetIfNeeded() async {
    try {
      // Check if user has any budgets at all
      final hasBudget = await _budgetService.hasActiveBudget();
      if (!hasBudget) {
        // Create a default budget
        _currentBudget = await _budgetService.createDefaultBudget();
      }
    } catch (e) {
      // Silently fail - user can create budget manually
      debugPrint('Failed to create default budget: $e');
    }
  }

  Future<void> _updateCurrentUsage() async {
    if (_currentBudget == null) return;

    try {
      // Calculate current usage from appliances
      final appliances = await _applianceService.getAllAppliances();
      final rate = await _rateService.getCurrentElectricityRate();

      if (rate != null && appliances.isNotEmpty) {
        double totalUsage = 0.0;
        for (final appliance in appliances) {
          totalUsage += appliance.calculateMonthlyCost(rate.ratePerKwh, appliance.hoursPerDay);
        }

        // Update budget with new usage
        final updatedBudget = _currentBudget!.updateUsage(totalUsage);
        await _budgetService.updateBudget(updatedBudget);
        _currentBudget = updatedBudget;

        // Check for budget alerts and send notifications
        if (_currentBudget!.alertsEnabled) {
          await _checkAndSendBudgetAlerts();
        }

        notifyListeners();
      }
    } catch (e) {
      // Silently fail - usage will be updated next time
      debugPrint('Failed to update current usage: $e');
    }
  }

  Future<void> _checkAndSendBudgetAlerts() async {
    if (_currentBudget == null) return;

    try {
      // Send budget threshold alert if approaching limit
      if (_currentBudget!.shouldAlert) {
        await _plannerNotificationService.sendBudgetThresholdAlert(
          currentUsage: _currentBudget!.currentUsage,
          budgetLimit: _currentBudget!.monthlyGoal,
          threshold: _currentBudget!.alertThreshold,
        );
      }

      // Send random planner tip occasionally
      if (DateTime.now().hour == 9 && DateTime.now().minute < 5) { // Once per day at 9 AM
        await _plannerNotificationService.sendRandomPlannerTip();
      }
    } catch (e) {
      debugPrint('Failed to send budget alerts: $e');
    }
  }

  /// Public method to refresh budget usage calculation
  Future<void> refreshBudgetUsage() async {
    await _updateCurrentUsage();
  }

  Future<bool> createBudget({
    required double monthlyGoal,
    double alertThreshold = 0.8,
    bool alertsEnabled = true,
  }) async {
    try {
      _currentBudget = await _budgetService.createBudget(
        monthlyGoal: monthlyGoal,
        alertThreshold: alertThreshold,
        alertsEnabled: alertsEnabled,
      );

      // Update usage immediately
      await _updateCurrentUsage();

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBudget({
    required double monthlyGoal,
    double? alertThreshold,
    bool? alertsEnabled,
  }) async {
    if (_currentBudget == null) return false;

    try {
      final updatedBudget = _currentBudget!.copyWith(
        monthlyGoal: monthlyGoal,
        alertThreshold: alertThreshold,
        alertsEnabled: alertsEnabled,
      );

      await _budgetService.updateBudget(updatedBudget);
      _currentBudget = updatedBudget;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshBudget() async {
    await loadCurrentBudget();
  }

  Future<void> deleteCurrentBudget() async {
    if (_currentBudget == null) return;

    try {
      await _budgetService.deleteBudget(_currentBudget!.id);
      _currentBudget = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
