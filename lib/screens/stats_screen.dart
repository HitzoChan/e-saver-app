import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../models/usage_record.dart';
import '../models/appliance.dart';
import '../models/appliance_category.dart';
import '../providers/usage_record_provider.dart';
import '../providers/appliance_provider.dart';

import '../screens/add_appliance_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  List<UsageRecord> _monthlyRecords = [];
  final Map<String, double> _applianceCosts = {};
  final List<ChartData> _weeklyTrendData = [];
  String _insightMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final usageProvider = Provider.of<UsageRecordProvider>(context, listen: false);
      final applianceProvider = Provider.of<ApplianceProvider>(context, listen: false);

      await Future.wait([
        usageProvider.loadUsageRecords(),
        applianceProvider.loadAppliances(),
      ]);

      await _processMonthlyData(usageProvider.usageRecords, applianceProvider.appliances);
      _generateWeeklyTrendData(usageProvider.usageRecords);
      _generateInsight(usageProvider.usageRecords);
    } catch (e) {
      debugPrint('Error loading stats data: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _processMonthlyData(List<UsageRecord> records, List<Appliance> appliances) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    _monthlyRecords = records.where((record) =>
      record.date.isAfter(startOfMonth.subtract(const Duration(days: 1)))).toList();

    // Calculate appliance costs
    _applianceCosts.clear();
    for (final record in _monthlyRecords) {
      final appliance = appliances.firstWhere(
        (a) => a.id == record.applianceId,
        orElse: () => Appliance.create(
          id: record.applianceId,
          name: 'Unknown Appliance',
          category: ApplianceCategory.other,
          wattage: 100,
          userId: '',
        ),
      );

      final cost = _applianceCosts[appliance.name] ?? 0.0;
      _applianceCosts[appliance.name] = cost + record.cost;
    }
  }

  void _generateWeeklyTrendData(List<UsageRecord> records) {
    final now = DateTime.now();
    _weeklyTrendData.clear();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayRecords = records.where((r) => r.isSameDate(date)).toList();
      final totalCost = dayRecords.fold<double>(0.0, (sum, r) => sum + r.cost);

      final dayName = DateFormat('EEE').format(date);
      _weeklyTrendData.add(ChartData(dayName, totalCost));
    }
  }

  void _generateInsight(List<UsageRecord> records) {
    if (records.isEmpty) {
      _insightMessage = '💡 Start tracking your appliance usage to get personalized energy-saving tips!';
      return;
    }

    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = currentWeekStart.subtract(const Duration(days: 7));

    final currentWeekRecords = records.where((r) => r.date.isAfter(currentWeekStart.subtract(const Duration(days: 1)))).toList();
    final lastWeekRecords = records.where((r) =>
      r.date.isAfter(lastWeekStart.subtract(const Duration(days: 1))) &&
      r.date.isBefore(currentWeekStart)).toList();

    final currentWeekCost = currentWeekRecords.fold<double>(0.0, (sum, r) => sum + r.cost);
    final lastWeekCost = lastWeekRecords.fold<double>(0.0, (sum, r) => sum + r.cost);

    if (lastWeekCost == 0) {
      _insightMessage = '💡 Great job starting to track your energy usage! Keep logging your appliance usage.';
      return;
    }

    final percentChange = ((currentWeekCost - lastWeekCost) / lastWeekCost) * 100;

    if (percentChange > 15) {
      _insightMessage = '⚠️ Your energy cost increased by ${percentChange.toStringAsFixed(1)}% this week. Try reducing usage by 1 hour/day to save PHP ${(currentWeekCost * 0.1).toStringAsFixed(2)} next month.';
    } else if (percentChange < -10) {
      _insightMessage = '🎉 Excellent! You saved PHP ${(lastWeekCost - currentWeekCost).toStringAsFixed(2)} compared to last week. Keep up the great work!';
    } else {
      _insightMessage = '✅ Your energy usage is stable. Consider small adjustments like unplugging unused devices to save more.';
    }
  }

  double get _totalMonthlyCost => _monthlyRecords.fold<double>(0.0, (sum, r) => sum + r.cost);
  double get _totalMonthlyKwh => _monthlyRecords.fold<double>(0.0, (sum, r) => sum + (r.hoursUsed * 1000) / 1000); // Simplified calculation
  double get _avgDailyCost => _totalMonthlyCost / DateTime.now().day;

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
              : LinearGradient(
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
              : LinearGradient(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your Usage Stats',
          style: TextStyle(
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
    );
  }

  Widget _buildSummaryCard() {
    final monthName = DateFormat('MMMM yyyy').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('${_totalMonthlyKwh.toStringAsFixed(1)} kWh', 'Total Usage'),
              _buildSummaryItem('PHP ${_totalMonthlyCost.toStringAsFixed(0)}', 'Total Cost'),
              _buildSummaryItem('PHP ${_avgDailyCost.toStringAsFixed(2)}', 'Avg/Day'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D47A1),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildApplianceBreakdown() {
    if (_applianceCosts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No appliance usage data yet.\nStart tracking to see breakdown!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
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
        color: Colors.white,
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
          const Text(
            'Appliance Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelFormat: 'PHP {value}',
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
        ],
      ),
    );
  }

  Widget _buildWeeklyTrend() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Text(
            'Weekly Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(fontSize: 12),
                majorGridLines: const MajorGridLines(width: 0),
              ),
              primaryYAxis: NumericAxis(
                labelFormat: 'PHP {value}',
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
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Energy Insight',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _insightMessage,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
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
