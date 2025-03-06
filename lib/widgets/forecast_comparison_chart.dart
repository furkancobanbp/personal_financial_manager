// lib/widgets/forecast_comparison_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class ForecastComparisonChart extends StatelessWidget {
  final Map<String, dynamic> comparisonData;

  const ForecastComparisonChart({
    Key? key,
    required this.comparisonData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract data from the comparison
    final incomeForecasted = comparisonData['summary']['income']['forecast'] as double;
    final incomeActual = comparisonData['summary']['income']['actual'] as double;
    
    final expensesForecasted = comparisonData['summary']['expenses']['forecast'] as double;
    final expensesActual = comparisonData['summary']['expenses']['actual'] as double;
    
    final netWorthForecasted = comparisonData['summary']['net_worth']['forecast'] as double;
    final netWorthActual = comparisonData['summary']['net_worth']['actual'] as double;

    // Find max value for Y-axis scaling
    final maxValue = [
      incomeForecasted, incomeActual,
      expensesForecasted, expensesActual,
      netWorthForecasted.abs(), netWorthActual.abs(),
    ].reduce((max, value) => value > max ? value : max);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.1,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.white.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String category;
                double forecastValue;
                double actualValue;

                switch (group.x) {
                  case 0:
                    category = 'Income';
                    forecastValue = incomeForecasted;
                    actualValue = incomeActual;
                    break;
                  case 1:
                    category = 'Expenses';
                    forecastValue = expensesForecasted;
                    actualValue = expensesActual;
                    break;
                  case 2:
                    category = 'Net Worth';
                    forecastValue = netWorthForecasted;
                    actualValue = netWorthActual;
                    break;
                  default:
                    category = '';
                    forecastValue = 0;
                    actualValue = 0;
                }

                final String value = rodIndex == 0
                    ? NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(forecastValue)
                    : NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(actualValue);

                final String label = rodIndex == 0 ? 'Forecast' : 'Actual';

                return BarTooltipItem(
                  '$category\n$label: $value',
                  TextStyle(
                    color: rodIndex == 0 ? Colors.blue : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  String text;
                  switch (value.toInt()) {
                    case 0:
                      text = 'Income';
                      break;
                    case 1:
                      text = 'Expenses';
                      break;
                    case 2:
                      text = 'Net Worth';
                      break;
                    default:
                      text = '';
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
                  if (value == 0) return const Text('');
                  
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
          gridData: const FlGridData(
            show: false,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
              left: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          barGroups: [
            // Income Group
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: incomeForecasted,
                  color: Colors.blue.shade300,
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: incomeActual,
                  color: Colors.green.shade400,
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            // Expenses Group
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: expensesForecasted,
                  color: Colors.blue.shade300,
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: expensesActual,
                  color: Colors.green.shade400,
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            // Net Worth Group
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: netWorthForecasted,
                  color: Colors.blue.shade300,
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: netWorthActual,
                  color: Colors.green.shade400,
                  width: 22,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}