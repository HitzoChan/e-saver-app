import 'package:flutter/material.dart';
import '../models/appliance.dart';
import '../models/electricity_rate.dart';
import '../models/notification.dart';
import '../services/appliance_service.dart';
import '../services/electricity_rate_service.dart';
import '../services/notification_storage_service.dart';

import 'dart:developer' as developer;

class DashboardProvider with ChangeNotifier {
  final ApplianceService _applianceService = ApplianceService();
  final ElectricityRateService _rateService = ElectricityRateService();
  final NotificationStorageService _notificationStorage = NotificationStorageService();

  List<Appliance> _appliances = [];
  ElectricityRate? _currentRate;
  bool _isLoading = true;
  String? _error;

  // Notification-related properties
  List<NotificationModel> _recentNotifications = [];
  bool _hasUnreadNotifications = false;
  String? _currentUserId;

  List<Appliance> get appliances => _appliances;
  ElectricityRate? get currentRate => _currentRate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Notification getters
  List<Map<String, dynamic>> get recentNotifications => _recentNotifications.map((n) => {
        'id': n.id,
        'type': n.type,
        'title': n.title,
        'subtitle': n.subtitle,
        'body': n.body,
        'time': n.getTimeAgo(),
        'icon': _getIconFromName(n.iconName),
        'color': _getColorFromHex(n.colorHex),
        'isRead': n.isRead,
        'data': n.data,
      }).toList();
  bool get hasUnreadNotifications => _hasUnreadNotifications;

  // Calculated values
  int get applianceCount => _appliances.length;
  double get totalMonthlyCost => _calculateTotalMonthlyCost();
  double get averageDailyUsage => _calculateAverageDailyUsage();
  List<double> get weeklyUsageData => _calculateWeeklyUsageData();
  List<String> get applianceLabels => _getApplianceLabels();

  Future<void> loadDashboardData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load appliances
      _appliances = await _applianceService.getAllAppliances();
      debugPrint('Loaded ${_appliances.length} appliances');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading appliances: $e');
      _error = 'Failed to load appliances: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }

    // Load electricity rate separately (non-blocking)
    _loadElectricityRate();

    // Load recent notifications
    loadRecentNotifications();
  }

  Future<void> _loadElectricityRate() async {
    try {
      _currentRate = await _rateService.getCurrentElectricityRate();
      notifyListeners();
    } catch (e) {
      // Don't set error for rate loading failure, just keep currentRate as null
      _currentRate = null;
      notifyListeners();
    }
  }

  double _calculateTotalMonthlyCost() {
    if (_currentRate == null) return 0.0;

    double total = 0.0;
    for (final appliance in _appliances) {
      total += appliance.calculateMonthlyCost(_currentRate!.ratePerKwh, appliance.hoursPerDay);
    }
    return total;
  }

  double _calculateAverageDailyUsage() {
    if (_appliances.isEmpty) return 0.0;

    double totalKwh = 0.0;
    for (final appliance in _appliances) {
      // Calculate daily kWh usage: (wattage * hoursPerDay) / 1000
      totalKwh += (appliance.wattage * appliance.hoursPerDay) / 1000;
    }
    return totalKwh;
  }

  List<double> _calculateWeeklyUsageData() {
    // Generate usage data based on actual daily kWh usage
    if (_appliances.isEmpty) {
      return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    }

    // Take up to 7 appliances for the graph
    final appliancesToShow = _appliances.take(7).toList();

    // Calculate daily kWh usage for each appliance
    final usageData = appliancesToShow.map((appliance) {
      return (appliance.wattage * appliance.hoursPerDay) / 1000;
    }).toList();

    // Pad with zeros if less than 7 appliances
    while (usageData.length < 7) {
      usageData.add(0.0);
    }

    return usageData;
  }

  List<String> _getApplianceLabels() {
    if (_appliances.isEmpty) {
      return ['No Appliances'];
    }

    // Take up to 7 appliances for the graph
    final appliancesToShow = _appliances.take(7).toList();

    // Generate labels with appliance names
    final labels = appliancesToShow.map((appliance) {
      // Truncate long names to fit
      final name = appliance.name.length > 8
          ? '${appliance.name.substring(0, 8)}...'
          : appliance.name;
      return name;
    }).toList();

    // Pad with empty strings if less than 7 appliances
    while (labels.length < 7) {
      labels.add('');
    }

    return labels;
  }

  void refresh() {
    loadDashboardData();
  }

  // Helper methods for icon and color conversion
  IconData _getIconFromName(String? iconName) {
    switch (iconName) {
      case 'notifications_active':
        return Icons.notifications_active;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'warning':
        return Icons.warning;
      case 'calendar_today':
        return Icons.calendar_today;
      case 'trending_up':
        return Icons.trending_up;
      case 'tips_and_updates':
        return Icons.tips_and_updates;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorFromHex(String? colorHex) {
    if (colorHex == null) return Colors.grey;
    try {
      return Color(int.parse(colorHex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  // Notification methods
  Future<void> loadRecentNotifications() async {
    if (_currentUserId == null) {
      // Load sample notifications if no user is logged in
      _loadSampleNotifications();
      return;
    }

    try {
      _recentNotifications = await _notificationStorage.getNotifications(_currentUserId!);
      _hasUnreadNotifications = _recentNotifications.any((notification) => !notification.isRead);
      notifyListeners();
    } catch (e) {
      developer.log('Error loading notifications: $e', name: 'DashboardProvider');
      // Fallback to sample notifications
      _loadSampleNotifications();
    }
  }

  // Method to refresh notifications (call this when returning to dashboard)
  Future<void> refreshNotifications() async {
    await loadRecentNotifications();
  }

  void _loadSampleNotifications() {
    _recentNotifications = [
      NotificationModel(
        id: '1',
        type: 'rate_update',
        title: 'Electricity Rate Update',
        body: 'New rate available for Meralco',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        iconName: 'notifications_active',
        colorHex: 'FF4CAF50',
      ),
      NotificationModel(
        id: '2',
        type: 'energy_tip',
        title: 'Energy Saving Tip',
        body: 'Unplug idle devices to save power',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
        iconName: 'lightbulb',
        colorHex: 'FF2196F3',
      ),
      NotificationModel(
        id: '3',
        type: 'budget_alert',
        title: 'Budget Alert',
        body: 'You\'ve exceeded 80% of your monthly budget',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: false,
        iconName: 'warning',
        colorHex: 'FFFF9800',
      ),
      NotificationModel(
        id: '4',
        type: 'weekly_report',
        title: 'Weekly Report',
        body: 'Your energy usage report is ready',
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        isRead: true,
        iconName: 'calendar_today',
        colorHex: 'FF2196F3',
      ),
    ];

    _hasUnreadNotifications = _recentNotifications.any((notification) => !notification.isRead);
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final index = _recentNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _recentNotifications[index] = _recentNotifications[index].copyWith(isRead: true);
      _hasUnreadNotifications = _recentNotifications.any((notification) => !notification.isRead);

      if (_currentUserId != null) {
        await _notificationStorage.markAsRead(_currentUserId!, notificationId);
      }

      notifyListeners();
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    for (int i = 0; i < _recentNotifications.length; i++) {
      _recentNotifications[i] = _recentNotifications[i].copyWith(isRead: true);
    }
    _hasUnreadNotifications = false;

    if (_currentUserId != null) {
      // Mark all as read in storage (this would need to be implemented in storage service)
      for (final notification in _recentNotifications) {
        await _notificationStorage.markAsRead(_currentUserId!, notification.id);
      }
    }

    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _recentNotifications.clear();
    _hasUnreadNotifications = false;

    if (_currentUserId != null) {
      await _notificationStorage.clearAllNotifications(_currentUserId!);
    }

    notifyListeners();
  }

  // Method to add a new notification
  Future<void> addNotification(NotificationModel notification) async {
    _recentNotifications.insert(0, notification); // Add to beginning
    _hasUnreadNotifications = true;

    if (_currentUserId != null) {
      await _notificationStorage.storeNotification(_currentUserId!, notification);
    }

    notifyListeners();
  }

  // Set current user ID for notification storage
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    loadRecentNotifications(); // Reload notifications for the new user
  }

  // Refresh notifications from storage (call this when returning to notifications screen)
  Future<void> refreshNotificationsFromStorage() async {
    await loadRecentNotifications();
  }
}
