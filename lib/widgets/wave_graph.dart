import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_colors.dart';

class WaveGraph extends StatefulWidget {
  final List<double> dataPoints;
  final List<String> labels;
  final double height;

  const WaveGraph({
    super.key,
    required this.dataPoints,
    required this.labels,
    this.height = 200,
  });

  @override
  State<WaveGraph> createState() => _WaveGraphState();
}

class _WaveGraphState extends State<WaveGraph> {
  final List<String> _selectedAppliances = [];

  @override
  Widget build(BuildContext context) {
    // Auto-scale calculation
    final maxDataValue = widget.dataPoints.isNotEmpty ? widget.dataPoints.reduce((a, b) => a > b ? a : b) : 0.0;
    final autoScaledMaxY = (maxDataValue * 1.2).ceilToDouble(); // Add 20% padding and round up
    final safeMaxY = autoScaledMaxY < 1 ? 1.0 : autoScaledMaxY; // Minimum of 1.0 (explicit double)

    return Column(
      children: [
        // Rounded Border Container with Wave Graph
        Container(
          height: widget.height,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: safeMaxY / 4, // Dynamic intervals based on max value
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withValues(alpha: 0.08),
                    strokeWidth: 0.5,
                    dashArray: [5, 5],
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Remove bottom titles from chart
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (widget.dataPoints.length - 1).toDouble() > 0 ? (widget.dataPoints.length - 1).toDouble() : 1.0,
              minY: 0,
              maxY: safeMaxY, // Auto-scaled maximum
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(
                    widget.dataPoints.length,
                    (index) => FlSpot(index.toDouble(), widget.dataPoints[index]),
                  ),
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentGreen.withValues(alpha: 0.9),
                      AppColors.mintGreen.withValues(alpha: 0.7),
                      AppColors.primaryBlue.withValues(alpha: 0.8),
                      AppColors.primaryBlue.withValues(alpha: 0.6),
                    ],
                    stops: const [0.0, 0.3, 0.7, 1.0],
                  ),
                  barWidth: 6,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentGreen.withValues(alpha: 0.15),
                        AppColors.mintGreen.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  if (event is FlTapUpEvent && touchResponse?.lineBarSpots != null) {
                    final spot = touchResponse!.lineBarSpots!.first;
                    final index = spot.x.toInt();
                    if (index < widget.labels.length && widget.labels[index].isNotEmpty) {
                      setState(() {
                        if (_selectedAppliances.contains(widget.labels[index])) {
                          _selectedAppliances.remove(widget.labels[index]);
                        } else {
                          _selectedAppliances.add(widget.labels[index]);
                        }
                      });
                    }
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: AppColors.primaryBlue.withValues(alpha: 0.95),
                  tooltipRoundedRadius: 12,
                  tooltipPadding: const EdgeInsets.all(12),
                  tooltipMargin: 8,
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final index = barSpot.x.toInt();
                      final label = index < widget.labels.length ? widget.labels[index] : '';
                      final value = barSpot.y.toStringAsFixed(2);
                      return LineTooltipItem(
                        '$label\n$value kW',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),

        // Horizontal Labels Under the Graph
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.labels.length,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    widget.labels[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Selected Appliances List
        if (_selectedAppliances.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Appliances',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedAppliances.map((appliance) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.accentGreen.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        appliance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
