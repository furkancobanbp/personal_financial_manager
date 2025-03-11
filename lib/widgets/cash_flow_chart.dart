// lib/widgets/cash_flow_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class CashFlowChart extends StatelessWidget {
  final Map<int, Map<String, double>> monthlyData;
  final int selectedYear;

  const CashFlowChart({
    super.key,
    required this.monthlyData,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    // Prepare data
    final List<FlSpot> spots = [];
    double maxY = 0.0;
    double minY = 0.0;
    
    for (int month = 1; month <= 12; month++) {
      final monthData = monthlyData[month];
      if (monthData != null) {
        final netWorth = monthData['net_worth'] ?? 0.0;
        spots.add(FlSpot(month.toDouble(), netWorth));
        
        if (netWorth > maxY) maxY = netWorth;
        if (netWorth < minY) minY = netWorth;
      }
    }
    
    // Ensure we have a buffer above and below the data points
    maxY = maxY * 1.1;
    minY = minY * 1.1;
    
    // If all values are positive, start from zero
    if (minY > 0) minY = 0;

    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 8.0),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateInterval(minY, maxY),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 1 || value > 12) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM').format(DateTime(selectedYear, value.toInt())),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
              left: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          minX: 1,
          maxX: 12,
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.netWorthLineColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  final value = spot.y;
                  return FlDotCirclePainter(
                    radius: 6,
                    color: value >= 0 ? AppColors.incomeBarColor : AppColors.expenseBarColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.netWorthLineColor.withOpacity(0.2),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final month = spot.x.toInt();
                  final value = spot.y;
                  return LineTooltipItem(
                    '${DateFormat('MMMM').format(DateTime(selectedYear, month))}\nNet Cash Flow: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(value)}',
                    TextStyle(
                      color: value >= 0 ? AppColors.incomeTextColor : AppColors.expenseTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          // Add reference line at zero
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 0,
                color: Colors.grey.withOpacity(0.8),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  double _calculateInterval(double min, double max) {
    final range = (max - min).abs();
    
    if (range <= 100) return 20;
    if (range <= 1000) return 200;
    if (range <= 10000) return 2000;
    return 10000;
  }
}