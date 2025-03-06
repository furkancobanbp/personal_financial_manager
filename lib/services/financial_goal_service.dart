// lib/services/financial_goal_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/financial_goal.dart';
import '../utils/id_generator.dart';
import '../utils/file_manager.dart';

class FinancialGoalService extends ChangeNotifier {
  List<FinancialGoal> _goals = [];
  static const String fileName = 'financial_goals.json';
  static const String assetPath = 'assets/data/financial_goals.json';
  
  List<FinancialGoal> get goals => List.unmodifiable(_goals);

  // Load goals from storage
  Future<void> loadGoals() async {
    try {
      final jsonList = await FileManager.readData(fileName, assetPath);
      _goals = jsonList.map((json) => FinancialGoal.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      print('Error loading goals: $e');
      _goals = [];
    }
  }

  // Save goals to storage
  Future<void> saveGoals() async {
    await FileManager.writeData(
      fileName, 
      _goals.map((g) => g.toJson()).toList()
    );
  }

  // Add a new goal
  Future<FinancialGoal> addGoal({
    required String name,
    required double amount,
    required GoalType goalType,
    required int year,
    required int month,
  }) async {
    final goal = FinancialGoal(
      id: IdGenerator.generateId(),
      name: name,
      amount: amount,
      goalType: goalType,
      year: year,
      month: month,
    );

    _goals.add(goal);
    await saveGoals();
    notifyListeners();
    return goal;
  }

  // Update a goal
  Future<bool> updateGoal({
    required String goalId,
    String? name,
    double? amount,
    GoalType? goalType,
    int? year,
    int? month,
    bool? active,
  }) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index < 0) return false;

    _goals[index] = _goals[index].copyWith(
      name: name,
      amount: amount,
      goalType: goalType,
      year: year,
      month: month,
      active: active,
    );

    await saveGoals();
    notifyListeners();
    return true;
  }

  // Remove a goal
  Future<bool> removeGoal(String goalId) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index >= 0) {
      _goals.removeAt(index);
      await saveGoals();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Get goals by month
  List<FinancialGoal> getGoalsByMonth(int year, int month) {
    return _goals.where((g) => 
      g.year == year && g.month == month && g.active
    ).toList();
  }

  // Calculate goal progress (requires transaction data)
  Map<String, dynamic> getGoalProgress(
    String goalId, 
    Map<String, double> monthlySummary
  ) {
    final goal = _goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => FinancialGoal(
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

    // Calculate current amount based on goal type
    double currentAmount = 0.0;
    if (goal.goalType == GoalType.income) {
      currentAmount = monthlySummary['total_income'] ?? 0.0;
    } else if (goal.goalType == GoalType.expense) {
      currentAmount = monthlySummary['total_expenses'] ?? 0.0;
    } else if (goal.goalType == GoalType.savings) {
      currentAmount = (monthlySummary['total_income'] ?? 0.0) - 
                      (monthlySummary['total_expenses'] ?? 0.0);
    }

    // Calculate percentage and remaining
    double percentage = goal.amount > 0 ? (currentAmount / goal.amount) * 100 : 0;
    
    // For expense goals, we want to stay under the amount, so invert the logic
    double remaining = 0.0;
    if (goal.goalType == GoalType.expense) {
      // If we're under budget, that's good!
      percentage = percentage.clamp(0.0, 100.0);
      remaining = goal.amount - currentAmount;
    } else {
      // For income/savings, we want to meet or exceed the goal
      percentage = percentage.clamp(0.0, 100.0);
      remaining = goal.amount - currentAmount;
    }

    return {
      'goal': goal,
      'current_amount': currentAmount,
      'percentage': percentage,
      'remaining': remaining,
    };
  }
}