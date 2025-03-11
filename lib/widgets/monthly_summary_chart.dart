// lib/widgets/monthly_summary_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class MonthlySummaryChart extends StatelessWidget {
  final Map<int, Map<String, double>> monthlyData;
  final int selectedYear;

  const MonthlySummaryChart({
    super.key,
    required this.monthlyData,
    required this.selectedYear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Income Chart
        Expanded(
          child: Column(
            children: [
              Text(
                'Income',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.incomeTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildBarChart('total_income', AppColors.incomeBarColor),
              ),
            ],
          ),
        ),
        
        // Expenses Chart
        Expanded(
          child: Column(
            children: [
              Text(
                'Expenses',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.expenseTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildBarChart('total_expenses', AppColors.expenseBarColor),
              ),
            ],
          ),
        ),
        
        // Net Worth Chart
        Expanded(
          child: Column(
            children: [
              Text(
                'Net Worth',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.netWorthTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildBarChart('net_worth', AppColors.netWorthLineColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(String dataKey, Color barColor) {
    final List<BarChartGroupData> barGroups = [];
    
    for (int month = 1; month <= 12; month++) {
      final monthData = monthlyData[month];
      if (monthData != null) {
        final value = monthData[dataKey] ?? 0.0;
        
        barGroups.add(
          BarChartGroupData(
            x: month,
            barRods: [
              BarChartRodData(
                toY: value.abs(),
                color: dataKey == 'net_worth' && value < 0 
                    ? AppColors.expenseBarColor 
                    : barColor,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
        );
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue(dataKey) * 1.1,
        titlesData: FlTitlesData(
          show: true,
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
                if (value == 0) return const Text('');
                
                final formatter = NumberFormat.compact();
                return Text(
                  formatter.format(value),
                  style: const TextStyle(fontSize: 10),
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
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
  
  double _getMaxValue(String dataKey) {
    double max = 0;
    for (int month = 1; month <= 12; month++) {
      final monthData = monthlyData[month];
      if (monthData != null) {
        final value = monthData[dataKey] ?? 0.0;
        if (value.abs() > max) {
          max = value.abs();
        }
      }
    }
    return max;
  }
}