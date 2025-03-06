// lib/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../utils/constants.dart';
import '../widgets/summary_card.dart';
import '../widgets/monthly_summary_chart.dart';
import '../widgets/cumulative_chart.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/cash_flow_chart.dart';
import '../widgets/forecast_comparison_chart.dart';

class DashboardView extends StatefulWidget {
  final AppController appController;

  const DashboardView({super.key, required this.appController});

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _overviewTabController;
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _overviewTabController = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _overviewTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the monthly summary for the selected month
    final summary = widget.appController.getMonthlySummary(
      _selectedYear,
      _selectedMonth,
    );
    final monthlyData = widget.appController.getMonthlyDataForYear(
      _selectedYear,
    );
    final years = widget.appController.getUniqueYears();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Period:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Month selector
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedMonth,
                              isDense: true,
                              items: List.generate(12, (index) {
                                return DropdownMenuItem<int>(
                                  value: index + 1,
                                  child: Text(
                                    DateFormat(
                                      'MMMM',
                                    ).format(DateTime(2022, index + 1)),
                                  ),
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
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Year selector
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: _selectedYear,
                              isDense: true,
                              items:
                                  years.map((year) {
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
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Refresh button
                      ElevatedButton.icon(
                        onPressed: () => setState(() {}),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
    final cumulativeData = widget.appController.getCumulativeData();

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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: TabBar(
                      controller: _overviewTabController,
                      tabs: const [Tab(text: 'Chart'), Tab(text: 'Table')],
                      labelColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      controller: _overviewTabController,
                      children: [
                        // Chart tab
                        MonthlySummaryChart(
                          monthlyData: monthlyData,
                          selectedYear: _selectedYear,
                        ),
                        // Table tab
                        _buildMonthlyDataTable(monthlyData),
                      ],
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
                    'Cumulative Financial Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child:
                        cumulativeData.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.bar_chart,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No cumulative data available. Add transactions to see the trend.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                            : CumulativeChart(cumulativeData: cumulativeData),
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
    // Get transactions for the selected month for the pie chart
    final transactions = widget.appController.transactionService
        .getTransactionsByMonth(_selectedYear, _selectedMonth);

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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: CashFlowChart(
                      monthlyData: monthlyData,
                      selectedYear: _selectedYear,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child:
                        transactions.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.pie_chart,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No expense data available for this period.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                            : CategoryBreakdownChart(
                              transactions: transactions,
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
      _selectedMonth,
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
                  SizedBox(
                    height: 300,
                    child: ForecastComparisonChart(
                      comparisonData: forecastComparison,
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
                    'Expense Categories: Forecast vs. Actual',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.pie_chart,
                                size: 40,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 8),
                              const Text('Forecasted'),
                              Text(
                                NumberFormat.currency(
                                  locale: 'tr_TR',
                                  symbol: '₺',
                                ).format(
                                  forecastComparison['summary']['expenses']['forecast'],
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.pie_chart,
                                size: 40,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 8),
                              const Text('Actual'),
                              Text(
                                NumberFormat.currency(
                                  locale: 'tr_TR',
                                  symbol: '₺',
                                ).format(
                                  forecastComparison['summary']['expenses']['actual'],
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                  child: Text(
                    'Month',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Income',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Expenses',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Net Worth',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
              color:
                  netWorth >= 0
                      ? AppColors.incomeTextColor
                      : AppColors.expenseTextColor,
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
                    child: Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Forecast',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Actual',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Variance',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              // Income row
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Income',
                      style: TextStyle(color: AppColors.incomeTextColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(
                        comparison['summary']['income']['forecast'],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(
                        comparison['summary']['income']['actual'],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${currencyFormat.format(comparison['summary']['income']['variance'])} (${comparison['summary']['income']['variance_pct'].toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color:
                            comparison['summary']['income']['variance'] >= 0
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
                    child: Text(
                      'Expenses',
                      style: TextStyle(color: AppColors.expenseTextColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(
                        comparison['summary']['expenses']['forecast'],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(
                        comparison['summary']['expenses']['actual'],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${currencyFormat.format(comparison['summary']['expenses']['variance'])} (${comparison['summary']['expenses']['variance_pct'].toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color:
                            comparison['summary']['expenses']['variance'] <= 0
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
                    child: Text(
                      'Net Worth',
                      style: TextStyle(color: AppColors.netWorthTextColor),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(
                        comparison['summary']['net_worth']['forecast'],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      currencyFormat.format(
                        comparison['summary']['net_worth']['actual'],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${currencyFormat.format(comparison['summary']['net_worth']['variance'])} (${comparison['summary']['net_worth']['variance_pct'].toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color:
                            comparison['summary']['net_worth']['variance'] >= 0
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
