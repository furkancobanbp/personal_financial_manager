// lib/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';

class DashboardView extends StatefulWidget {
  final AppController appController;

  const DashboardView({
    super.key, 
    required this.appController,
  });

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Financial Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildMonthlyDataTable(monthlyData),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cumulative Financial Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Cumulative financial data visualization\ncoming soon in the next update',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(Map<int, Map<String, double>> monthlyData) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Cash Flow Trend',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.trending_up, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Cash flow trend visualization\ncoming soon in the next update',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expense Breakdown by Category',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pie_chart, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'Category breakdown visualization\ncoming soon in the next update',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastAnalysisTab() {
    final forecastComparison = widget.appController.compareForecastVsActual(
      _selectedYear, 
      _selectedMonth
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Forecast vs. Actual - ${DateFormat('MMMM yyyy').format(DateTime(_selectedYear, _selectedMonth))}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildForecastComparisonTable(forecastComparison),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category-Level Comparison',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: const Center(
                      child: Text(
                        'Detailed category comparison will be available in the next update.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyDataTable(Map<int, Map<String, double>> monthlyData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1.5),
            2: FlexColumnWidth(1.5),
            3: FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Month', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Income', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Expenses', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Net Worth', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            
            // Data rows
            for (int month = 1; month <= 12; month++)
              _buildMonthRow(month, monthlyData[month]),
          ],
        ),
      ),
    );
  }

  TableRow _buildMonthRow(int month, Map<String, double>? data) {
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    
    final monthName = DateFormat('MMMM').format(DateTime(2022, month));
    final income = data?['total_income'] ?? 0.0;
    final expenses = data?['total_expenses'] ?? 0.0;
    final netWorth = data?['net_worth'] ?? 0.0;
    
    // Highlight current month
    final isCurrentMonth = month == _selectedMonth;
    final bgColor = isCurrentMonth ? Colors.grey.shade100 : null;
    
    return TableRow(
      decoration: BoxDecoration(color: bgColor),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            monthName,
            style: TextStyle(
              fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            currencyFormat.format(income),
            style: TextStyle(
              color: AppColors.incomeTextColor,
              fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            currencyFormat.format(expenses),
            style: TextStyle(
              color: AppColors.expenseTextColor,
              fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            currencyFormat.format(netWorth),
            style: TextStyle(
              color: netWorth >= 0 ? AppColors.incomeTextColor : AppColors.expenseTextColor,
              fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastComparisonTable(Map<String, dynamic> comparison) {
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1.5),
            },
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade200),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Forecast', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Actual', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Variance', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              
              // Income row
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Income', style: TextStyle(color: AppColors.incomeTextColor)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(comparison['summary']['income']['forecast']),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(comparison['summary']['income']['actual']),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${currencyFormat.format(comparison['summary']['income']['variance'])} (${comparison['summary']['income']['variance_pct'].toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: comparison['summary']['income']['variance'] >= 0
                            ? AppColors.incomeTextColor
                            : AppColors.expenseTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Expenses row
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Expenses', style: TextStyle(color: AppColors.expenseTextColor)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(comparison['summary']['expenses']['forecast']),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(comparison['summary']['expenses']['actual']),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${currencyFormat.format(comparison['summary']['expenses']['variance'])} (${comparison['summary']['expenses']['variance_pct'].toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: comparison['summary']['expenses']['variance'] <= 0
                            ? AppColors.incomeTextColor
                            : AppColors.expenseTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Net Worth row
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Net Worth', style: TextStyle(color: AppColors.netWorthTextColor)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(comparison['summary']['net_worth']['forecast']),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(comparison['summary']['net_worth']['actual']),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${currencyFormat.format(comparison['summary']['net_worth']['variance'])} (${comparison['summary']['net_worth']['variance_pct'].toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: comparison['summary']['net_worth']['variance'] >= 0
                            ? AppColors.incomeTextColor
                            : AppColors.expenseTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Note: Positive variances for income indicate actual income exceeded forecasts.\n'
              'Negative variances for expenses indicate actual expenses were lower than forecasts.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}