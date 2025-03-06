// lib/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';
import '../widgets/chart_container.dart';

class DashboardView extends StatefulWidget {
  final AppController appController;

  const DashboardView({
    Key? key, 
    required this.appController,
  }) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _selectedYear;
  late int _selectedMonth;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the monthly summary for the selected month
    final summary = widget.appController.getMonthlySummary(_selectedYear, _selectedMonth);
    final monthlyData = widget.appController.getMonthlyDataForYear(_selectedYear);
    final years = widget.appController.getUniqueYears();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          Row(
            children: [
              const Text('Year:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedYear,
                items: years.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedYear = value;
                    });
                  }
                },
              ),
              const SizedBox(width: 16),
              const Text('Month:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedMonth,
                items: List.generate(12, (index) {
                  return DropdownMenuItem<int>(
                    value: index + 1,
                    child: Text(DateFormat('MMMM').format(DateTime(2022, index + 1))),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  }
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Summary cards
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Income',
                  amount: summary['total_income'] ?? 0,
                  backgroundColor: AppColors.incomeBackgroundColor,
                  textColor: AppColors.incomeTextColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: 'Total Expenses',
                  amount: summary['total_expenses'] ?? 0,
                  backgroundColor: AppColors.expenseBackgroundColor,
                  textColor: AppColors.expenseTextColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: 'Net Worth',
                  amount: summary['net_worth'] ?? 0,
                  backgroundColor: AppColors.netWorthBackgroundColor,
                  textColor: AppColors.netWorthTextColor,
                  showSign: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tab bar for charts
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Insights'),
              Tab(text: 'Forecast Analysis'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
          ),
          
          const SizedBox(height: 16),
          
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                _buildOverviewTab(monthlyData),
                
                // Insights Tab
                _buildInsightsTab(monthlyData),
                
                // Forecast Analysis Tab
                _buildForecastAnalysisTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Map<int, Map<String, double>> monthlyData) {
    return Row(
      children: [
        // Monthly chart
        Expanded(
          child: ChartContainer(
            title: 'Monthly Financial Summary',
            child: _buildMonthlyChart(monthlyData),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Cumulative chart
        Expanded(
          child: ChartContainer(
            title: 'Cumulative Financial Overview',
            child: _buildCumulativeChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsTab(Map<int, Map<String, double>> monthlyData) {
    return Row(
      children: [
        // Trend chart
        Expanded(
          child: ChartContainer(
            title: 'Monthly Cash Flow Trend',
            child: _buildTrendChart(monthlyData),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Category chart
        Expanded(
          child: ChartContainer(
            title: 'Expense Breakdown by Category',
            child: _buildCategoryChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastAnalysisTab() {
    final forecastComparison = widget.appController.compareForecastVsActual(
      _selectedYear, 
      _selectedMonth
    );

    return Row(
      children: [
        // Forecast vs Actual Summary
        Expanded(
          child: ChartContainer(
            title: 'Forecast vs Actual Summary',
            child: _buildForecastSummaryChart(forecastComparison),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Category Comparison
        Expanded(
          child: ChartContainer(
            title: 'Forecast vs Actual by Category',
            child: _buildForecastCategoryChart(forecastComparison),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyChart(Map<int, Map<String, double>> monthlyData) {
    final List<BarChartGroupData> barGroups = [];
    final List<double> incomeValues = [];
    final List<double> expenseValues = [];
    final List<double> netValues = [];

    for (int month = 1; month <= 12; month++) {
      final data = monthlyData[month];
      if (data != null) {
        incomeValues.add(data['total_income'] ?? 0);
        expenseValues.add(data['total_expenses'] ?? 0);
        netValues.add(data['net_worth'] ?? 0);

        barGroups.add(
          BarChartGroupData(
            x: month - 1,
            barRods: [
              BarChartRodData(
                toY: data['total_income'] ?? 0,
                color: AppColors.incomeBarColor,
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
              BarChartRodData(
                toY: -(data['total_expenses'] ?? 0),
                color: AppColors.expenseBarColor,
                width: 10,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: incomeValues.isEmpty ? 1000 : incomeValues.reduce((a, b) => a > b ? a : b) * 1.2,
        minY: expenseValues.isEmpty ? -1000 : -expenseValues.reduce((a, b) => a > b ? a : b) * 1.2,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                return Text(
                  months[value.toInt()],
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1000,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildCumulativeChart() {
    // This would be implemented with LineChart from fl_chart
    // For brevity, returning a placeholder
    return const Center(
      child: Text('Cumulative Chart Placeholder'),
    );
  }

  Widget _buildTrendChart(Map<int, Map<String, double>> monthlyData) {
    // This would be implemented with LineChart from fl_chart
    // For brevity, returning a placeholder
    return const Center(
      child: Text('Trend Chart Placeholder'),
    );
  }

  Widget _buildCategoryChart() {
    // This would be implemented with PieChart from fl_chart
    // For brevity, returning a placeholder
    return const Center(
      child: Text('Category Chart Placeholder'),
    );
  }

  Widget _buildForecastSummaryChart(Map<String, dynamic> comparison) {
    // This would be implemented with grouped BarChart from fl_chart
    // For brevity, returning a placeholder
    return const Center(
      child: Text('Forecast Summary Chart Placeholder'),
    );
  }

  Widget _buildForecastCategoryChart(Map<String, dynamic> comparison) {
    // This would be implemented with grouped BarChart from fl_chart
    // For brevity, returning a placeholder
    return const Center(
      child: Text('Forecast Category Chart Placeholder'),
    );
  }
}