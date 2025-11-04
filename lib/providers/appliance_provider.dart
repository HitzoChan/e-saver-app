import 'package:flutter/foundation.dart';
import '../models/appliance.dart';
import '../models/electricity_rate.dart';
import '../services/appliance_service.dart';
import '../services/electricity_rate_service.dart';

class ApplianceProvider with ChangeNotifier {
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

  // Calculated values for Add Appliance Screen
  int get connectionCount => _appliances.length;
  double get averageMonthlyBill => _calculateAverageMonthlyBill();
  double get householdAverageUsage => _calculateHouseholdAverageUsage();

  Future<void> loadAppliances() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appliances = await _applianceService.getAllAppliances();
      _currentRate = await _rateService.getCurrentElectricityRate();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  double _calculateAverageMonthlyBill() {
    if (_currentRate == null || _appliances.isEmpty) return 0.0; // Default fallback

    double totalMonthly = 0.0;
    for (final appliance in _appliances) {
      totalMonthly += appliance.calculateMonthlyCost(_currentRate!.ratePerKwh, appliance.hoursPerDay);
    }
    return totalMonthly;
  }

  double _calculateHouseholdAverageUsage() {
    if (_appliances.isEmpty) return 0.0; // Default fallback

    double totalKwh = 0.0;
    for (final appliance in _appliances) {
      // Calculate daily kWh usage: (wattage * hoursPerDay) / 1000
      totalKwh += (appliance.wattage * appliance.hoursPerDay) / 1000;
    }
    // Assume average household has more appliances, so multiply by a factor
    return totalKwh * 1.5; // Multiplier for typical household
  }

  Future<void> addAppliance(Appliance appliance) async {
    try {
      await _applianceService.addAppliance(appliance);
      _appliances.add(appliance);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAppliance(Appliance appliance) async {
    try {
      await _applianceService.updateAppliance(appliance);
      final index = _appliances.indexWhere((a) => a.id == appliance.id);
      if (index != -1) {
        _appliances[index] = appliance;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAppliance(String applianceId) async {
    try {
      await _applianceService.deleteAppliance(applianceId);
      _appliances.removeWhere((a) => a.id == applianceId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addBuiltInAppliance(String applianceId) async {
    try {
      await _applianceService.addBuiltInAppliance(applianceId);
      await loadAppliances(); // Refresh the list after adding
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void refresh() {
    loadAppliances();
  }
}
