// lib/views/forecast_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../models/forecast_transaction.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class ForecastView extends StatefulWidget {
  final AppController appController;

  const ForecastView({
    super.key,
    required this.appController,
  });

  @override
  _ForecastViewState createState() => _ForecastViewState();
}

class _ForecastViewState extends State<ForecastView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  
  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Add Forecast'),
              Tab(text: 'View Forecasts'),
              Tab(text: 'Compare with Actual'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
          ),
          
          const SizedBox(height: 16),
          
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Add Forecast Tab
                _buildAddForecastTab(),
                
                // View Forecasts Tab
                _buildViewForecastsTab(),
                
                // Compare with Actual Tab
                _buildCompareTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddForecastTab() {
    // Get all categories
    final categories = widget.appController.getAllCategories();
    
    // Group categories by type
    final incomeCategories = categories
        .where((c) => c.type == TransactionType.income)
        .map((c) => c.name)
        .toList();
        
    final expenseCategories = categories
        .where((c) => c.type == TransactionType.expense)
        .map((c) => c.name)
        .toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Enter Forecast Transaction Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Transaction name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Transaction Name',
                  hintText: 'e.g., Expected Salary, Planned Rent Payment',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a transaction name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (₺)',
                  hintText: 'Forecast amount in Turkish Lira',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  try {
                    final amount = double.parse(value);
                    if (amount <= 0) {
                      return 'Amount must be positive';
                    }
                  } catch (e) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Select a category'),
                  ),
                  // Income categories group
                  if (incomeCategories.isNotEmpty) 
                    const DropdownMenuItem<String>(
                      value: 'income_header',
                      enabled: false,
                      child: Text(
                        'INCOME CATEGORIES',
                        style: TextStyle(
                          color: AppColors.incomeTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ...incomeCategories.map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      '$category (Income)',
                      style: const TextStyle(color: AppColors.incomeTextColor),
                    ),
                  )),
                  
                  // Expense categories group
                  if (expenseCategories.isNotEmpty) 
                    const DropdownMenuItem<String>(
                      value: 'expense_header',
                      enabled: false,
                      child: Text(
                        'EXPENSE CATEGORIES',
                        style: TextStyle(
                          color: AppColors.expenseTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ...expenseCategories.map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      '$category (Expense)',
                      style: const TextStyle(color: AppColors.expenseTextColor),
                    ),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Date picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMMM yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add notes or assumptions about this forecast',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _clearForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addForecast,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Add Forecast'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewForecastsTab() {
    // Get forecasts for selected period
    final forecasts = widget.appController.getForecastsByMonth(_selectedYear, _selectedMonth);
    
    // Split by type
    final incomeForecasts = forecasts
        .where((f) => f.transactionType == TransactionType.income)
        .toList();
        
    final expenseForecasts = forecasts
        .where((f) => f.transactionType == TransactionType.expense)
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period filter
        Row(
          children: [
            const Text(
              'Period:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            const SizedBox(width: 16),
            DropdownButton<int>(
              value: _selectedYear,
              items: widget.appController.getUniqueYears().map((year) {
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
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Forecast tables
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Income forecasts
              Expanded(
                child: _buildForecastTable(
                  'Income Forecasts',
                  incomeForecasts,
                  AppColors.incomeTextColor,
                  AppColors.incomeBackgroundColor,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Expense forecasts
              Expanded(
                child: _buildForecastTable(
                  'Expense Forecasts',
                  expenseForecasts,
                  AppColors.expenseTextColor,
                  AppColors.expenseBackgroundColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompareTab() {
    final comparison = widget.appController.compareForecastVsActual(_selectedYear, _selectedMonth);
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Row(
              children: [
                const Text(
                  'Select Period for Comparison:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: widget.appController.getUniqueYears().map((year) {
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
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Compare'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Summary card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
                    
                    // Summary table
                    Table(
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1.5),
                      },
                      children: [
                        // Headers
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Forecast',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Actual',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Variance',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        
                        // Income row
                        _buildComparisonRow(
                          'Income',
                          comparison['summary']['income'],
                          AppColors.incomeTextColor,
                        ),
                        
                        // Expenses row
                        _buildComparisonRow(
                          'Expenses',
                          comparison['summary']['expenses'],
                          AppColors.expenseTextColor,
                        ),
                        
                        // Net row
                        _buildComparisonRow(
                          'Net Worth',
                          comparison['summary']['net_worth'],
                          AppColors.netWorthTextColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Summary explanation
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Note: Positive variances for income indicate actual income exceeded forecasts.\n'
                  'Negative variances for expenses indicate actual expenses were lower than forecasts.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildComparisonRow(
    String label,
    Map<String, dynamic> data,
    Color color,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );
    
    final forecast = data['forecast'] as double;
    final actual = data['actual'] as double;
    final variance = data['variance'] as double;
    final variancePct = data['variance_pct'] as double;
    
    // Determine if variance is good or bad
    bool isGoodVariance;
    if (label == 'Income' || label == 'Net Worth') {
      isGoodVariance = variance >= 0;
    } else {
      isGoodVariance = variance <= 0;
    }
    
    final varianceColor = isGoodVariance ? AppColors.incomeTextColor : AppColors.expenseTextColor;
    
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            currencyFormat.format(forecast),
            textAlign: TextAlign.right,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            currencyFormat.format(actual),
            textAlign: TextAlign.right,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${currencyFormat.format(variance)} (${variancePct.toStringAsFixed(1)}%)',
            style: TextStyle(
              color: varianceColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastTable(
    String title,
    List<ForecastTransaction> forecasts,
    Color headerColor,
    Color headerBackgroundColor,
  ) {
    // Calculate total amount
    final totalAmount = forecasts.fold(
      0.0,
      (sum, forecast) => sum + forecast.amount,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: headerBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: headerColor,
              ),
            ),
          ),
          
          // Table
          Expanded(
            child: forecasts.isEmpty
                ? Center(
                    child: Text(
                      'No ${title.toLowerCase()} found for this period',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: forecasts.length,
                    itemBuilder: (context, index) {
                      final forecast = forecasts[index];
                      
                      return ListTile(
                        title: Text(
                          forecast.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${forecast.category ?? 'N/A'} • ${DateFormat('MMM yyyy').format(forecast.date)}',
                            ),
                            if (forecast.notes != null && forecast.notes!.isNotEmpty)
                              Text(
                                forecast.notes!,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              NumberFormat.currency(
                                locale: 'tr_TR',
                                symbol: '₺',
                              ).format(forecast.amount),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: headerColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (forecast.realized)
                              const Tooltip(
                                message: 'Realized',
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: forecast.notes != null && forecast.notes!.isNotEmpty,
                      );
                    },
                  ),
          ),
          
          // Footer with total
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    locale: 'tr_TR',
                    symbol: '₺',
                  ).format(totalAmount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: headerColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      
    );
    
    if (pickedDate != null) {
      setState(() {
        // Set day to 1 since we only care about month and year
        _selectedDate = DateTime(pickedDate.year, pickedDate.month, 1);
      });
    }
  }

  void _clearForm() {
    _nameController.clear();
    _amountController.clear();
    _notesController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedDate = DateTime.now();
    });
  }

  // lib/views/forecast_view.dart (continued)
  void _addForecast() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      try {
        final amount = double.parse(_amountController.text);
        
        final success = await widget.appController.addForecast(
          name: _nameController.text,
          amount: amount,
          categoryName: _selectedCategory!,
          date: _selectedDate,
          notes: _notesController.text,
        );
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Forecast transaction added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add forecast. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}