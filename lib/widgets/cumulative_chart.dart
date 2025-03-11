// lib/widgets/cumulative_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class CumulativeChart extends StatelessWidget {
  final List<Map<String, dynamic>> cumulativeData;

  const CumulativeChart({
    super.key,
    required this.cumulativeData,
  });

  @override
  Widget build(BuildContext context) {
    if (cumulativeData.isEmpty) {
      return const Center(
        child: Text(
          'No data available for cumulative chart',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16.0),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.white.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  final data = cumulativeData[spot.x.toInt()];
                  final date = data['date'] as DateTime;
                  String label;
                  double value;
                  
                  switch (spot.barIndex) {
                    case 0:
                      label = 'Income';
                      value = data['cumulative_income'] as double;
                      break;
                    case 1:
                      label = 'Expenses';
                      value = data['cumulative_expenses'] as double;
                      break;
                    case 2:
                      label = 'Net Worth';
                      value = data['cumulative_net'] as double;
                      break;
                    default:
                      label = '';
                      value = 0;
                  }
                  
                  return LineTooltipItem(
                    '${DateFormat('MMM yyyy').format(date)}\n$label: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(value)}',
                    TextStyle(
                      color: _getLineColor(spot.barIndex),
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _calculateInterval(),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= cumulativeData.length || value.toInt() < 0) {
                    return const Text('');
                  }
                  
                  // Show only every n-th month to avoid crowding
                  final step = (cumulativeData.length / 6).ceil();
                  if (value.toInt() % step != 0 && value.toInt() != cumulativeData.length - 1) {
                    return const Text('');
                  }
                  
                  final date = cumulativeData[value.toInt()]['date'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM yy').format(date),
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
          minX: 0,
          maxX: cumulativeData.length - 1.0,
          minY: _calculateMinY(),
          maxY: _calculateMaxY(),
          lineBarsData: [
            // Income line
            _createLineData(0, 'cumulative_income', AppColors.incomeBarColor),
            
            // Expenses line
            _createLineData(1, 'cumulative_expenses', AppColors.expenseBarColor),
            
            // Net Worth line
            _createLineData(2, 'cumulative_net', AppColors.netWorthLineColor),
          ],
        ),
      ),
    );
  }
  
  LineChartBarData _createLineData(int index, String key, Color color) {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < cumulativeData.length; i++) {
      final value = cumulativeData[i][key] as double;
      spots.add(FlSpot(i.toDouble(), value));
    }
    
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
    );
  }
  
  Color _getLineColor(int index) {
    switch (index) {
      case 0:
        return AppColors.incomeBarColor;
      case 1:
        return AppColors.expenseBarColor;
      case 2:
        return AppColors.netWorthLineColor;
      default:
        return Colors.grey;
    }
  }
  
  double _calculateMinY() {
    double minValue = 0;
    
    for (final data in cumulativeData) {
      final netWorth = data['cumulative_net'] as double;
      if (netWorth < minValue) {
        minValue = netWorth;
      }
    }
    
    return minValue * 1.1; // Add some padding
  }
  
  double _calculateMaxY() {
    double maxValue = 0;
    
    for (final data in cumulativeData) {
      final income = data['cumulative_income'] as double;
      final expenses = data['cumulative_expenses'] as double;
      final netWorth = data['cumulative_net'] as double;
      
      final maxOfRow = [income, expenses, netWorth].reduce((max, value) => value > max ? value : max);
      
      if (maxOfRow > maxValue) {
        maxValue = maxOfRow;
      }
    }
    
    return maxValue * 1.1; // Add some padding
  }
  
  double _calculateInterval() {
    final maxY = _calculateMaxY();
    final minY = _calculateMinY();
    final range = maxY - minY;
    
    if (range <= 100) return 20;
    if (range <= 1000) return 200;
    if (range <= 10000) return 2000;
    return 10000;
  }
}