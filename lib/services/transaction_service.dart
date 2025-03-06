// lib/services/transaction_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../utils/id_generator.dart';
import '../utils/file_manager.dart';

class TransactionService extends ChangeNotifier {
  List<Transaction> _transactions = [];
  static const String fileName = 'finance_data.json';
  static const String assetPath = 'assets/data/finance_data.json';
  
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  // Load transactions from storage
  Future<void> loadTransactions() async {
    try {
      final jsonList = await FileManager.readData(fileName, assetPath);
      _transactions = jsonList.map((json) => Transaction.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading transactions: $e');
      _transactions = [];
    }
  }

  // Save transactions to storage
  Future<void> saveTransactions() async {
    await FileManager.writeData(
      fileName, 
      _transactions.map((t) => t.toJson()).toList()
    );
  }

  // Add a new transaction
  Future<Transaction> addTransaction({
    required String name,
    required double amount,
    required String categoryName,
    required TransactionType transactionType,
    required DateTime date,
  }) async {
    final transaction = Transaction(
      id: IdGenerator.generateId(),
      name: name,
      amount: amount,
      transactionType: transactionType,
      date: date,
      category: categoryName,
    );

    _transactions.add(transaction);
    await saveTransactions();
    notifyListeners();
    return transaction;
  }

  // Remove a transaction
  Future<bool> removeTransaction(String transactionId) async {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index >= 0) {
      _transactions.removeAt(index);
      await saveTransactions();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Get transactions by month and year
  List<Transaction> getTransactionsByMonth(int year, int month) {
    return _transactions.where((t) => 
      t.date.year == year && t.date.month == month
    ).toList();
  }

  // Get monthly summary (income, expenses, net worth)
  Map<String, double> getMonthlySummary(int year, int month) {
    final transactionsInMonth = getTransactionsByMonth(year, month);
    
    final totalIncome = transactionsInMonth
        .where((t) => t.transactionType == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalExpenses = transactionsInMonth
        .where((t) => t.transactionType == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    return {
      'total_income': totalIncome,
      'total_expenses': totalExpenses,
      'net_worth': totalIncome - totalExpenses,
    };
  }

  // Get monthly data for an entire year
  Map<int, Map<String, double>> getMonthlyDataForYear(int year) {
    final monthlyData = <int, Map<String, double>>{};
    
    for (int month = 1; month <= 12; month++) {
      monthlyData[month] = getMonthlySummary(year, month);
    }
    
    return monthlyData;
  }

  // Get unique years from transaction data
  List<int> getUniqueYears() {
    final years = _transactions.map((t) => t.date.year).toSet().toList();
    years.sort();
    if (years.isEmpty) {
      years.add(DateTime.now().year);
    }
    return years;
  }

  // Get cumulative financial data
  List<Map<String, dynamic>> getCumulativeData() {
    // Sort transactions by date
    final sortedTransactions = List<Transaction>.from(_transactions)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    double cumulativeIncome = 0;
    double cumulativeExpenses = 0;
    
    return sortedTransactions.map((transaction) {
      if (transaction.transactionType == TransactionType.income) {
        cumulativeIncome += transaction.amount;
      } else {
        cumulativeExpenses += transaction.amount;
      }
      
      final cumulativeNet = cumulativeIncome - cumulativeExpenses;
      
      return {
        'date': transaction.date,
        'cumulative_income': cumulativeIncome,
        'cumulative_expenses': cumulativeExpenses,
        'cumulative_net': cumulativeNet,
      };
    }).toList();
  }
}