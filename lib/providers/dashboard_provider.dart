import 'package:flutter/foundation.dart';
import '../models/appliance.dart';
import '../models/electricity_rate.dart';
import '../services/appliance_service.dart';
import '../services/electricity_rate_service.dart';

class DashboardProvider with ChangeNotifier {
  final ApplianceService _applianceService = ApplianceService();
  final ElectricityRateService _rateService = ElectricityRateService();

  List<Appliance> _appliances = [];
  ElectricityRate? _currentRate;
  bool _isLoading = true;
  String? _error;

  List<Appliance> get appliances => _appliances;
  ElectricityRate? get currentRate => _currentRate;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
}
