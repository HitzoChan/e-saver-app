import 'package:flutter/foundation.dart';
import '../models/usage_record.dart';
import '../services/usage_record_service.dart';

class UsageRecordProvider with ChangeNotifier {
  final UsageRecordService _usageRecordService = UsageRecordService();

  List<UsageRecord> _usageRecords = [];
  Map<DateTime, double> _weeklyDailyUsage = {};
  bool _isLoading = true;
  String? _error;

  List<UsageRecord> get usageRecords => _usageRecords;
  Map<DateTime, double> get weeklyDailyUsage => _weeklyDailyUsage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculated values
  double get totalWeeklyCost => _calculateTotalWeeklyCost();
  double get totalWeeklyHours => _calculateTotalWeeklyHours();
  int get daysTracked => _weeklyDailyUsage.length;

  Future<void> loadUsageRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _usageRecords = await _usageRecordService.getAllUsageRecords();
      _weeklyDailyUsage = await _usageRecordService.getWeeklyDailyUsage();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeeklyData() async {
    try {
      _weeklyDailyUsage = await _usageRecordService.getWeeklyDailyUsage();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> addUsageRecord(UsageRecord record) async {
    try {
      await _usageRecordService.addUsageRecord(record);
      _usageRecords.insert(0, record); // Add to beginning since ordered by date desc
      await loadWeeklyData(); // Refresh weekly data
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateUsageRecord(UsageRecord record) async {
    try {
      await _usageRecordService.updateUsageRecord(record);
      final index = _usageRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        _usageRecords[index] = record;
        await loadWeeklyData(); // Refresh weekly data
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteUsageRecord(String recordId) async {
    try {
      await _usageRecordService.deleteUsageRecord(recordId);
      _usageRecords.removeWhere((r) => r.id == recordId);
      await loadWeeklyData(); // Refresh weekly data
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<UsageRecord> createUsageRecord({
    required String applianceId,
    required DateTime date,
    required double hoursUsed,
    required int wattage,
    required double ratePerKwh,
    String? notes,
  }) async {
    try {
      final record = await _usageRecordService.createUsageRecord(
        applianceId: applianceId,
        date: date,
        hoursUsed: hoursUsed,
        wattage: wattage,
        ratePerKwh: ratePerKwh,
        notes: notes,
      );

      _usageRecords.insert(0, record);
      await loadWeeklyData();
      notifyListeners();
      return record;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<UsageRecord>> getUsageRecordsByAppliance(String applianceId) async {
    try {
      return await _usageRecordService.getUsageRecordsByAppliance(applianceId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  double _calculateTotalWeeklyCost() {
    return _usageRecords
        .where((record) => record.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .fold<double>(0.0, (sum, record) => sum + record.cost);
  }

  double _calculateTotalWeeklyHours() {
    return _usageRecords
        .where((record) => record.date.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .fold<double>(0.0, (sum, record) => sum + record.hoursUsed);
  }

  void refresh() {
    loadUsageRecords();
  }
}
