// lib/controllers/app_controller.dart
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/financial_goal.dart';
import '../models/forecast_transaction.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/financial_goal_service.dart';
import '../services/forecast_service.dart';

class AppController {
  final TransactionService transactionService;
  final CategoryService categoryService;
  final FinancialGoalService goalService;
  final ForecastService forecastService;

  AppController({
    required this.transactionService,
    required this.categoryService,
    required this.goalService,
    required this.forecastService,
  });

  // Transaction methods
  Future<bool> addTransaction({
    required String name,
    required double amount,
    required String categoryName,
    required DateTime date,
  }) async {
    try {
      // Get the transaction type from the category
      final categoryType = categoryService.getCategoryType(categoryName);
      if (categoryType == null) {
        return false;
      }

      final transaction = await transactionService.addTransaction(
        name: name,
        amount: amount,
        categoryName: categoryName,
        transactionType: categoryType,
        date: date,
      );

      // Check if this transaction matches any forecasts and mark as realized
      final matchingForecast = forecastService.findMatchingForecast(
        transaction,
      );
      if (matchingForecast != null) {
        await forecastService.markForecastRealized(
          matchingForecast.id,
          transaction.id,
        );
      }

      return true;
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  // Financial summary methods
  Map<String, double> getMonthlySummary(int year, int month) {
    return transactionService.getMonthlySummary(year, month);
  }

  Map<int, Map<String, double>> getMonthlyDataForYear(int year) {
    return transactionService.getMonthlyDataForYear(year);
  }

  List<Map<String, dynamic>> getCumulativeData() {
    return transactionService.getCumulativeData();
  }

  List<int> getUniqueYears() {
    return transactionService.getUniqueYears();
  }

  // Category management methods
  Future<bool> addCategory(String name, TransactionType categoryType) {
    return categoryService.addCategory(name, categoryType);
  }

  Future<bool> removeCategory(String name) {
    return categoryService.removeCategory(name);
  }

  Future<bool> updateCategory(
    String oldName,
    String newName,
    TransactionType categoryType,
  ) {
    return categoryService.updateCategory(oldName, newName, categoryType);
  }

  List<Category> getAllCategories() {
    return categoryService.categories;
  }

  List<String> getCategoriesByType(TransactionType categoryType) {
    return categoryService.getCategoriesByType(categoryType);
  }

  // Financial Goals Methods
  Future<bool> addGoal({
    required String name,
    required double amount,
    required GoalType goalType,
    required int year,
    required int month,
  }) async {
    try {
      await goalService.addGoal(
        name: name,
        amount: amount,
        goalType: goalType,
        year: year,
        month: month,
      );
      return true;
    } catch (e) {
      print('Error adding goal: $e');
      return false;
    }
  }

  Future<bool> updateGoal({
    required String goalId,
    String? name,
    double? amount,
    GoalType? goalType,
    int? year,
    int? month,
    bool? active,
  }) {
    return goalService.updateGoal(
      goalId: goalId,
      name: name,
      amount: amount,
      goalType: goalType,
      year: year,
      month: month,
      active: active,
    );
  }

  Future<bool> removeGoal(String goalId) {
    return goalService.removeGoal(goalId);
  }

  List<FinancialGoal> getGoalsByMonth(int year, int month) {
    return goalService.getGoalsByMonth(year, month);
  }

  // lib/controllers/app_controller.dart (continued)
  Map<String, dynamic> getGoalProgress(String goalId) {
    final goal = goalService.goals.firstWhere(
      (g) => g.id == goalId,
      orElse:
          () => FinancialGoal(
            id: '',
            name: '',
            amount: 0,
            goalType: GoalType.income,
            year: 0,
            month: 0,
          ),
    );

    if (goal.id.isEmpty) {
      return {
        'goal': null,
        'current_amount': 0.0,
        'percentage': 0.0,
        'remaining': 0.0,
      };
    }

    final monthlySummary = transactionService.getMonthlySummary(
      goal.year,
      goal.month,
    );
    return goalService.getGoalProgress(goalId, monthlySummary);
  }

  List<FinancialGoal> getAllGoals() {
    return goalService.goals;
  }

  // Forecast Methods
  Future<bool> addForecast({
    required String name,
    required double amount,
    required String categoryName,
    required DateTime date,
    String notes = '',
  }) async {
    try {
      // Get the transaction type from the category
      final categoryType = categoryService.getCategoryType(categoryName);
      if (categoryType == null) {
        return false;
      }

      await forecastService.addForecast(
        name: name,
        amount: amount,
        categoryName: categoryName,
        categoryType: categoryType,
        date: date,
        notes: notes,
      );
      return true;
    } catch (e) {
      print('Error adding forecast: $e');
      return false;
    }
  }

  Future<bool> updateForecast({
    required String forecastId,
    String? name,
    double? amount,
    String? categoryName,
    DateTime? date,
    String? notes,
  }) async {
    try {
      TransactionType? categoryType;
      if (categoryName != null) {
        categoryType = categoryService.getCategoryType(categoryName);
        if (categoryType == null) {
          return false;
        }
      }

      return await forecastService.updateForecast(
        forecastId: forecastId,
        name: name,
        amount: amount,
        categoryName: categoryName,
        categoryType: categoryType,
        date: date,
        notes: notes,
      );
    } catch (e) {
      print('Error updating forecast: $e');
      return false;
    }
  }

  Future<bool> removeForecast(String forecastId) {
    return forecastService.removeForecast(forecastId);
  }

  List<ForecastTransaction> getForecastsByMonth(int year, int month) {
    return forecastService.getForecastsByMonth(year, month);
  }

  List<ForecastTransaction> getAllForecasts() {
    return forecastService.forecasts;
  }

  Map<String, double> getForecastMonthlySummary(int year, int month) {
    return forecastService.getMonthlySummary(year, month);
  }

  Map<String, dynamic> compareForecastVsActual(int year, int month) {
    final actualSummary = transactionService.getMonthlySummary(year, month);
    return forecastService.compareWithActual(actualSummary, year, month);
  }

  // Extended Forecast Methods
  Future<bool> markForecastRealized(String forecastId, String transactionId) {
    return forecastService.markForecastRealized(forecastId, transactionId);
  }

  Future<bool> convertTransactionToForecast(String transactionId) async {
    try {
      // Find the transaction
      final transaction = transactionService.transactions.firstWhere(
        (t) => t.id == transactionId,
        orElse:
            () => Transaction(
              id: '',
              name: '',
              amount: 0,
              transactionType: TransactionType.income,
              date: DateTime.now(),
            ),
      );

      if (transaction.id.isEmpty) {
        return false;
      }

      // Create a forecast from it
      await forecastService.createForecastFromTransaction(transaction);
      return true;
    } catch (e) {
      print('Error converting transaction to forecast: $e');
      return false;
    }
  }
}
