// lib/widgets/category_breakdown_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class CategoryBreakdownChart extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Color> colorPalette;

  const CategoryBreakdownChart({
    super.key,
    required this.transactions,
    this.colorPalette = const [
      Color(0xFFF44336), // Red
      Color(0xFF9C27B0), // Purple
      Color(0xFF3F51B5), // Indigo
      Color(0xFF03A9F4), // Light Blue
      Color(0xFF009688), // Teal
      Color(0xFF8BC34A), // Light Green
      Color(0xFFFFEB3B), // Yellow
      Color(0xFFFF9800), // Orange
      Color(0xFF795548), // Brown
      Color(0xFF607D8B), // Blue Grey
    ],
  });

  @override
  State<CategoryBreakdownChart> createState() => _CategoryBreakdownChartState();
}

class _CategoryBreakdownChartState extends State<CategoryBreakdownChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // Filter to only include expense transactions
    final expenseTransactions = widget.transactions
        .where((t) => t.transactionType == TransactionType.expense)
        .toList();

    if (expenseTransactions.isEmpty) {
      return const Center(
        child: Text(
          'No expense data available',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Group transactions by category
    final Map<String, double> categorySums = {};
    for (var transaction in expenseTransactions) {
      final category = transaction.category ?? 'Uncategorized';
      categorySums[category] = (categorySums[category] ?? 0) + transaction.amount;
    }

    // Convert to list of CategoryData
    final List<MapEntry<String, double>> categoryData = categorySums.entries.toList();
    
    // Sort by amount (largest to smallest)
    categoryData.sort((a, b) => b.value.compareTo(a.value));
    
    // Total expenses
    final totalExpenses = expenseTransactions.fold(
      0.0,
      (sum, t) => sum + t.amount,
    );

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: _buildPieSections(categoryData, totalExpenses),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              startDegreeOffset: 180,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Legend
        SizedBox(
          height: 100,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                categoryData.length,
                (index) => _buildLegendItem(
                  categoryData[index].key,
                  categoryData[index].value,
                  totalExpenses,
                  widget.colorPalette[index % widget.colorPalette.length],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        Text(
          'Total Expenses: ${NumberFormat.currency(
            locale: 'tr_TR',
            symbol: '₺',
          ).format(totalExpenses)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(
    List<MapEntry<String, double>> categoryData,
    double totalExpenses,
  ) {
    return List.generate(categoryData.length, (index) {
      final category = categoryData[index].key;
      final amount = categoryData[index].value;
      final percentage = (amount / totalExpenses) * 100;
      final isTouched = index == touchedIndex;
      
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 110.0 : 100.0;
      
      return PieChartSectionData(
        color: widget.colorPalette[index % widget.colorPalette.length],
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegendItem(String category, double amount, double total, Color color) {
    final percentage = (amount / total) * 100;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            NumberFormat.currency(
              locale: 'tr_TR',
              symbol: '₺',
            ).format(amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}