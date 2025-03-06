// lib/services/forecast_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/forecast_transaction.dart';
import '../models/transaction.dart';
import '../utils/id_generator.dart';

class ForecastService extends ChangeNotifier {
  List<ForecastTransaction> _forecasts = [];
  
  List<ForecastTransaction> get forecasts => List.unmodifiable(_forecasts);

  // Load forecasts from storage
  Future<void> loadForecasts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('forecasts') ?? '[]';
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      _forecasts = jsonList.map((json) => ForecastTransaction.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading forecasts: $e');
      _forecasts = [];
    }
  }

  // Save forecasts to storage
  Future<void> saveForecasts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_forecasts.map((f) => f.toJson()).toList());
    await prefs.setString('forecasts', jsonString);
  }

  // Add a new forecast
  Future<ForecastTransaction> addForecast({
    required String name,
    required double amount,
    required String categoryName,
    required TransactionType categoryType,
    required DateTime date,
    String notes = '',
  }) async {
    final forecast = ForecastTransaction(
      id: IdGenerator.generateId(),
      name: name,
      amount: amount,
      transactionType: categoryType,
      date: date,
      category: categoryName,
      notes: notes,
    );

    _forecasts.add(forecast);
    await saveForecasts();
    notifyListeners();
    return forecast;
  }

  // Update a forecast
  Future<bool> updateForecast({
    required String forecastId,
    String? name,
    double? amount,
    String? categoryName,
    TransactionType? categoryType,
    DateTime? date,
    String? notes,
  }) async {
    final index = _forecasts.indexWhere((f) => f.id == forecastId);
    if (index < 0) return false;

    _forecasts[index] = _forecasts[index].copyWith(
      name: name,
      amount: amount,
      category: categoryName,
      transactionType: categoryType,
      date: date,
      notes: notes,
    );

    await saveForecasts();
    notifyListeners();
    return true;
  }

  // Remove a forecast
  Future<bool> removeForecast(String forecastId) async {
    final index = _forecasts.indexWhere((f) => f.id == forecastId);
    if (index >= 0) {
      _forecasts.removeAt(index);
      await saveForecasts();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Get forecasts by month
  List<ForecastTransaction> getForecastsByMonth(int year, int month) {
    return _forecasts.where((f) => 
      f.date.year == year && f.date.month == month
    ).toList();
  }

  // Get monthly summary of forecasts
  Map<String, double> getMonthlySummary(int year, int month) {
    final forecastsInMonth = getForecastsByMonth(year, month);
    
    final totalIncome = forecastsInMonth
        .where((f) => f.transactionType == TransactionType.income)
        .fold(0.0, (sum, f) => sum + f.amount);
    
    final totalExpenses = forecastsInMonth
        .where((f) => f.transactionType == TransactionType.expense)
        .fold(0.0, (sum, f) => sum + f.amount);
    
    return {
      'total_income': totalIncome,
      'total_expenses': totalExpenses,
      'net_worth': totalIncome - totalExpenses,
    };
  }

  // Find a matching forecast for a transaction
  ForecastTransaction? findMatchingForecast(Transaction transaction) {
    // Find forecasts for the same month/year
    final forecastsInMonth = getForecastsByMonth(
      transaction.date.year, 
      transaction.date.month
    );
    
    // Get forecasts that match category and type, and are not yet realized
    final matches = forecastsInMonth.where((f) => 
      !f.realized && 
      f.category == transaction.category &&
      f.transactionType == transaction.transactionType
    ).toList();
    
    if (matches.isEmpty) return null;
    
    // Find the closest match by amount
    matches.sort((a, b) =>
      (a.amount - transaction.amount).abs().compareTo(
        (b.amount - transaction.amount).abs()
      )
    );
    
    // Only consider a match if within 10% difference
    final closestMatch = matches.first;
    if ((closestMatch.amount - transaction.amount).abs() <= (closestMatch.amount * 0.1)) {
      return closestMatch;
    }
    
    return null;
  }

  // Mark a forecast as realized
  Future<bool> markForecastRealized(String forecastId, String transactionId) async {
    final index = _forecasts.indexWhere((f) => f.id == forecastId);
    if (index < 0) return false;

    _forecasts[index] = _forecasts[index].copyWith(
      actualTransactionId: transactionId,
      realized: true,
    );

    await saveForecasts();
    notifyListeners();
    return true;
  }

  // Create a forecast from an existing transaction
  Future<ForecastTransaction> createForecastFromTransaction(Transaction transaction) async {
    final forecast = ForecastTransaction(
      id: IdGenerator.generateId(),
      name: "[Forecast] ${transaction.name}",
      amount: transaction.amount,
      transactionType: transaction.transactionType,
      date: transaction.date,
      category: transaction.category,
      notes: "Created from transaction ${transaction.id}",
    );

    _forecasts.add(forecast);
    await saveForecasts();
    notifyListeners();
    return forecast;
  }

  // Compare forecast with actual data
  Map<String, dynamic> compareWithActual(
    Map<String, double> actualSummary, 
    int year, 
    int month
  ) {
    final forecastSummary = getMonthlySummary(year, month);
    
    // Calculate variances
    final incomeVariance = actualSummary['total_income']! - forecastSummary['total_income']!;
    final incomeVariancePct = forecastSummary['total_income']! > 0 
        ? (incomeVariance / forecastSummary['total_income']! * 100) 
        : 0.0;
    
    final expenseVariance = actualSummary['total_expenses']! - forecastSummary['total_expenses']!;
    final expenseVariancePct = forecastSummary['total_expenses']! > 0 
        ? (expenseVariance / forecastSummary['total_expenses']! * 100) 
        : 0.0;
    
    final netVariance = actualSummary['net_worth']! - forecastSummary['net_worth']!;
    final netVariancePct = forecastSummary['net_worth']! != 0 
        ? (netVariance / forecastSummary['net_worth']!.abs() * 100) 
        : 0.0;
    
    return {
      'summary': {
        'income': {
          'forecast': forecastSummary['total_income'],
          'actual': actualSummary['total_income'],
          'variance': incomeVariance,
          'variance_pct': incomeVariancePct,
        },
        'expenses': {
          'forecast': forecastSummary['total_expenses'],
          'actual': actualSummary['total_expenses'],
          'variance': expenseVariance,
          'variance_pct': expenseVariancePct,
        },
        'net_worth': {
          'forecast': forecastSummary['net_worth'],
          'actual': actualSummary['net_worth'],
          'variance': netVariance,
          'variance_pct': netVariancePct,
        },
      },
      // Additional category-level comparisons would be added here
    };
  }
}