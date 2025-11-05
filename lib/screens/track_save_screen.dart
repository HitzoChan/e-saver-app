import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/appliance.dart';
import '../providers/appliance_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/add_appliance_screen.dart';

class TrackSaveScreen extends StatefulWidget {
  const TrackSaveScreen({super.key});

  @override
  State<TrackSaveScreen> createState() => _TrackSaveScreenState();
}

class _TrackSaveScreenState extends State<TrackSaveScreen> {
  bool _isLoading = true;
  List<Appliance> _appliances = [];
  final Map<String, double> _applianceCosts = {};
  final List<ChartData> _weeklyTrendData = [];
  String _insightMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    // Listen to settings changes to update insights when language changes
    Provider.of<SettingsProvider>(context, listen: false).addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    Provider.of<SettingsProvider>(context, listen: false).removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    _generateInsight(_appliances);
    setState(() {});
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final applianceProvider = Provider.of<ApplianceProvider>(context, listen: false);
      await applianceProvider.loadAppliances();

      _appliances = applianceProvider.appliances;
      _processApplianceData(_appliances, applianceProvider.currentRate?.ratePerKwh ?? 12.0);
      _generateWeeklyTrendData(_appliances, applianceProvider.currentRate?.ratePerKwh ?? 12.0);
      _generateInsight(_appliances);
    } catch (e) {
      debugPrint('Error loading stats data: $e');
    }

    setState(() => _isLoading = false);
  }

  void _processApplianceData(List<Appliance> appliances, double ratePerKwh) {
    // Calculate monthly costs for each appliance
    _applianceCosts.clear();
    for (final appliance in appliances) {
      final monthlyCost = appliance.calculateMonthlyCost(ratePerKwh, appliance.hoursPerDay);
      _applianceCosts[appliance.name] = monthlyCost;
    }
  }

  void _generateWeeklyTrendData(List<Appliance> appliances, double ratePerKwh) {
    final now = DateTime.now();
    _weeklyTrendData.clear();

    // Generate estimated weekly trend based on appliance usage patterns
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Estimate daily cost based on appliances (simplified assumption)
      final dailyCost = appliances.fold<double>(0.0, (sum, appliance) =>
        sum + appliance.calculateDailyCost(ratePerKwh, appliance.hoursPerDay));

      final dayName = DateFormat('EEE').format(date);
      _weeklyTrendData.add(ChartData(dayName, dailyCost));
    }
  }

  void _generateInsight(List<Appliance> appliances) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    if (appliances.isEmpty) {
      _insightMessage = settingsProvider.getLocalizedText('no_appliance_insight');
      return;
    }

    final totalMonthlyCost = _totalMonthlyCost;

    // Generate insights based on appliance data
    if (totalMonthlyCost > 2000) {
      _insightMessage = settingsProvider.getLocalizedText('high_bill_insight')
          .replaceAll('{cost}', totalMonthlyCost.toStringAsFixed(0))
          .replaceAll('{currencySymbol}', settingsProvider.currencySymbol);
    } else if (totalMonthlyCost > 1000) {
      _insightMessage = settingsProvider.getLocalizedText('medium_bill_insight')
          .replaceAll('{cost}', totalMonthlyCost.toStringAsFixed(0))
          .replaceAll('{currencySymbol}', settingsProvider.currencySymbol);
    } else {
      _insightMessage = settingsProvider.getLocalizedText('low_bill_insight')
          .replaceAll('{cost}', totalMonthlyCost.toStringAsFixed(0))
          .replaceAll('{currencySymbol}', settingsProvider.currencySymbol);
    }

    // Add appliance-specific tips
    final highUsageAppliances = appliances.where((a) => a.wattage > 1000).toList();
    if (highUsageAppliances.isNotEmpty) {
      _insightMessage += '\n\n${settingsProvider.getLocalizedText('tip_monitor_usage')
          .replaceAll('{appliance}', '${highUsageAppliances.first.name} (${highUsageAppliances.first.wattage}W)')}';
    }
  }

  double get _totalMonthlyCost {
    if (_appliances.isEmpty) return 0.0;
    final rate = Provider.of<ApplianceProvider>(context, listen: false).currentRate?.ratePerKwh ?? 12.0;
    return _appliances.fold<double>(0.0, (sum, appliance) =>
      sum + appliance.calculateMonthlyCost(rate, appliance.hoursPerDay));
  }

  double get _totalMonthlyKwh {
    if (_appliances.isEmpty) return 0.0;
    return _appliances.fold<double>(0.0, (sum, appliance) =>
      sum + (appliance.wattage * appliance.hoursPerDay * 30 / 1000)); // Monthly calculation
  }

  double get _avgDailyCost {
    if (_appliances.isEmpty) return 0.0;
    final rate = Provider.of<ApplianceProvider>(context, listen: false).currentRate?.ratePerKwh ?? 12.0;
    return _appliances.fold<double>(0.0, (sum, appliance) =>
      sum + appliance.calculateDailyCost(rate, appliance.hoursPerDay));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.grey[900]!,
                      Colors.grey[800]!,
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                  ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.grey[900]!,
                    Colors.grey[800]!,
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AppBar
                  _buildAppBar(),

                  const SizedBox(height: 24),

                  // Summary Card
                  _buildSummaryCard(),


                  const SizedBox(height: 24),

                  // Appliance Breakdown Chart
                  _buildApplianceBreakdown(),

                  const SizedBox(height: 24),

                  // Weekly Trend Chart
                  _buildWeeklyTrend(),

                  const SizedBox(height: 24),

                  // Insight Card
                  _buildInsightCard(),

                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            settings.getLocalizedText('Your Usage Stats'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final monthName = DateFormat('MMMM yyyy').format(DateTime.now());
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF0D47A1)),
                  const SizedBox(width: 8),
                  Text(
                    monthName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0D47A1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: _buildSummaryItem('${_totalMonthlyKwh.toStringAsFixed(1)} kWh', settings.getLocalizedText('Total Usage'), isDark),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _buildSummaryItem('${settings.currencySymbol}${_totalMonthlyCost.toStringAsFixed(0)}', settings.getLocalizedText('Total Cost'), isDark),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: _buildSummaryItem('${settings.currencySymbol}${_avgDailyCost.toStringAsFixed(2)}', 'Avg/Day', isDark),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String value, String label, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildApplianceBreakdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_applianceCosts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        ),
        child: Consumer<SettingsProvider>(
          builder: (context, settings, child) => Center(
            child: Text(
              settings.getLocalizedText('No appliance usage data yet.\nStart tracking to see breakdown!'),
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
            ),
          ),
        ),
      );
    }

    final sortedCosts = _applianceCosts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topAppliances = sortedCosts.take(sortedCosts.length).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => Text(
              settings.getLocalizedText('Appliance Breakdown'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D47A1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => SizedBox(
              height: 200,
              child: SfCartesianChart(
                key: ValueKey(settings.currency),
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(fontSize: 12),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '${settings.currencySymbol} {value}',
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),
                series: <CartesianSeries<ChartData, String>>[
                  BarSeries<ChartData, String>(
                    dataSource: topAppliances.map((e) => ChartData(e.key, e.value)).toList(),
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: const Color(0xFF42A5F5),
                    borderRadius: BorderRadius.circular(4),
                    width: 0.6,
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrend() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => Text(
              settings.getLocalizedText('Weekly Trend'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0D47A1),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => SizedBox(
              height: 200,
              child: SfCartesianChart(
                key: ValueKey(settings.currency),
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(fontSize: 12),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelFormat: '${settings.currencySymbol} {value}',
                  majorGridLines: const MajorGridLines(width: 0.5),
                ),
                series: <CartesianSeries<ChartData, String>>[
                  LineSeries<ChartData, String>(
                    dataSource: _weeklyTrendData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: const Color(0xFF10B981),
                    width: 3,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildInsightCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) => Row(
              children: [
                const Icon(Icons.lightbulb, color: Color(0xFF10B981)),
                const SizedBox(width: 8),
                Text(
                  settings.getLocalizedText('Energy Insight'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _insightMessage,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to add appliance screen (assuming for adding usage)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddApplianceScreen()),
        );
      },
      backgroundColor: const Color(0xFF10B981),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
