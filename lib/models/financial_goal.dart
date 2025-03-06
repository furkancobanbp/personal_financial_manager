// lib/models/financial_goal.dart

enum GoalType {
  income,
  expense,
  savings
}

class FinancialGoal {
  final String id;
  final String name;
  final double amount;
  final GoalType goalType;
  final int year;
  final int month;
  final bool active;

  FinancialGoal({
    required this.id,
    required this.name,
    required this.amount,
    required this.goalType,
    required this.year,
    required this.month,
    this.active = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'goal_type': goalType.toString().split('.').last,
      'year': year,
      'month': month,
      'active': active,
    };
  }

  factory FinancialGoal.fromJson(Map<String, dynamic> json) {
    return FinancialGoal(
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      goalType: GoalType.values.firstWhere(
          (e) => e.toString().split('.').last == json['goal_type']),
      year: json['year'],
      month: json['month'],
      active: json['active'] ?? true,
    );
  }

  FinancialGoal copyWith({
    String? id,
    String? name,
    double? amount,
    GoalType? goalType,
    int? year,
    int? month,
    bool? active,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      goalType: goalType ?? this.goalType,
      year: year ?? this.year,
      month: month ?? this.month,
      active: active ?? this.active,
    );
  }
}