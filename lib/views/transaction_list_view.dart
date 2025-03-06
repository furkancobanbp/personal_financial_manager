// lib/views/transaction_list_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class TransactionListView extends StatefulWidget {
  final AppController appController;

  const TransactionListView({
    super.key,
    required this.appController,
  });

  @override
  _TransactionListViewState createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  String _selectedPeriod = 'current_month';
  
  @override
  Widget build(BuildContext context) {
    // Get transactions based on selected period
    final transactions = _getTransactionsByPeriod();
    
    // Split by type
    final incomeTransactions = transactions
        .where((t) => t.transactionType == TransactionType.income)
        .toList();
        
    final expenseTransactions = transactions
        .where((t) => t.transactionType == TransactionType.expense)
        .toList();
    
    // Sort by date (newest first)
    incomeTransactions.sort((a, b) => b.date.compareTo(a.date));
    expenseTransactions.sort((a, b) => b.date.compareTo(a.date));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period filter
          Row(
            children: [
              const Text(
                'Period:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _selectedPeriod,
                items: const [
                  DropdownMenuItem(
                    value: 'current_month',
                    child: Text('Current Month'),
                  ),
                  DropdownMenuItem(
                    value: 'previous_month',
                    child: Text('Previous Month'),
                  ),
                  DropdownMenuItem(
                    value: 'current_year',
                    child: Text('Current Year'),
                  ),
                  DropdownMenuItem(
                    value: 'previous_year',
                    child: Text('Previous Year'),
                  ),
                  DropdownMenuItem(
                    value: 'all_time',
                    child: Text('All Time'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                    });
                  }
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tables
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Income transactions
                Expanded(
                  child: _buildTransactionTable(
                    'Income Transactions',
                    incomeTransactions,
                    AppColors.incomeTextColor,
                    AppColors.incomeBackgroundColor,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Expense transactions
                Expanded(
                  child: _buildTransactionTable(
                    'Expense Transactions',
                    expenseTransactions,
                    AppColors.expenseTextColor,
                    AppColors.expenseBackgroundColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTable(
    String title,
    List<Transaction> transactions,
    Color headerColor,
    Color headerBackgroundColor,
  ) {
    // Calculate total amount
    final totalAmount = transactions.fold(
      0.0,
      (sum, transaction) => sum + transaction.amount,
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
            child: transactions.isEmpty
                ? Center(
                    child: Text(
                      'No ${title.toLowerCase()} found for this period',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      
                      return ListTile(
                        title: Text(
                          transaction.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${transaction.category ?? 'N/A'} • ${DateFormat('MMM yyyy').format(transaction.date)}',
                        ),
                        trailing: Text(
                          NumberFormat.currency(
                            locale: 'tr_TR',
                            symbol: '₺',
                          ).format(transaction.amount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: headerColor,
                          ),
                        ),
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

  List<Transaction> _getTransactionsByPeriod() {
    final now = DateTime.now();
    final allTransactions = widget.appController.transactionService.transactions;
    
    switch (_selectedPeriod) {
      case 'current_month':
        return widget.appController.transactionService.getTransactionsByMonth(now.year, now.month);
        
      case 'previous_month':
        final prevMonth = now.month == 1 ? 12 : now.month - 1;
        final prevYear = now.month == 1 ? now.year - 1 : now.year;
        return widget.appController.transactionService.getTransactionsByMonth(prevYear, prevMonth);
        
      case 'current_year':
        return allTransactions.where((t) => t.date.year == now.year).toList();
        
      case 'previous_year':
        return allTransactions.where((t) => t.date.year == now.year - 1).toList();
        
      case 'all_time':
      default:
        return allTransactions;
    }
  }
}