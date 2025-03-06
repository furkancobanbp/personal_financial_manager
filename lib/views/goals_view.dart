// lib/views/goals_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../models/financial_goal.dart';
import '../utils/constants.dart';

class GoalsView extends StatefulWidget {
  final AppController appController;

  const GoalsView({super.key, required this.appController});

  @override
  _GoalsViewState createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  GoalType _selectedGoalType = GoalType.income;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get active goals for selected month
    final goals = widget.appController.getGoalsByMonth(
      _selectedYear,
      _selectedMonth,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Goals list
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
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
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _selectedYear,
                      items:
                          widget.appController.getUniqueYears().map((year) {
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

                // Goals list
                Expanded(
                  child:
                      goals.isEmpty
                          ? const Center(
                            child: Text(
                              'No goals set for this period. Create a new goal to get started!',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          )
                          : ListView.builder(
                            itemCount: goals.length,
                            itemBuilder: (context, index) {
                              final goal = goals[index];
                              final progress = widget.appController
                                  .getGoalProgress(goal.id);

                              return _buildGoalCard(context, goal, progress);
                            },
                          ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Add goal form
          Expanded(
            flex: 1,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New Goal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Goal name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Goal Name',
                          hintText:
                              'e.g., Monthly Salary Target, Grocery Budget',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a goal name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Goal amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Target Amount (₺)',
                          hintText: 'Target amount in Turkish Lira',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a target amount';
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

                      // Goal type
                      DropdownButtonFormField<GoalType>(
                        value: _selectedGoalType,
                        decoration: const InputDecoration(
                          labelText: 'Goal Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: GoalType.income,
                            child: Text('Income Goal'),
                          ),
                          DropdownMenuItem(
                            value: GoalType.expense,
                            child: Text('Expense Budget'),
                          ),
                          DropdownMenuItem(
                            value: GoalType.savings,
                            child: Text('Savings Target'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGoalType = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Period selection
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedMonth,
                              decoration: const InputDecoration(
                                labelText: 'Month',
                                border: OutlineInputBorder(),
                              ),
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

                          const SizedBox(width: 16),

                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedYear,
                              decoration: const InputDecoration(
                                labelText: 'Year',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  widget.appController.getUniqueYears().map((
                                    year,
                                  ) {
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
                        ],
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
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Clear'),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: _addGoal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('Add Goal'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // lib/views/goals_view.dart (continued)
  Widget _buildGoalCard(
    BuildContext context,
    FinancialGoal goal,
    Map<String, dynamic> progress,
  ) {
    // Determine colors based on goal type
    Color backgroundColor;
    Color textColor;
    Color progressColor;

    switch (goal.goalType) {
      case GoalType.income:
        backgroundColor = AppColors.incomeBackgroundColor;
        textColor = AppColors.incomeTextColor;
        progressColor = AppColors.incomeBarColor;
        break;
      case GoalType.expense:
        backgroundColor = AppColors.expenseBackgroundColor;
        textColor = AppColors.expenseTextColor;
        progressColor = AppColors.expenseBarColor;
        break;
      case GoalType.savings:
        backgroundColor = AppColors.netWorthBackgroundColor;
        textColor = AppColors.netWorthTextColor;
        progressColor = AppColors.netWorthLineColor;
        break;
    }

    // Format currency
    final currencyFormat = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    // Get progress values
    final currentAmount = progress['current_amount'] as double;
    final percentage = progress['percentage'] as double;
    final remaining = progress['remaining'] as double;

    // Description text based on goal type
    String description = '';
    switch (goal.goalType) {
      case GoalType.income:
        description =
            'Income goal for ${DateFormat('MMMM yyyy').format(DateTime(goal.year, goal.month))}';
        break;
      case GoalType.expense:
        description =
            'Expense budget for ${DateFormat('MMMM yyyy').format(DateTime(goal.year, goal.month))}';
        break;
      case GoalType.savings:
        description =
            'Savings target for ${DateFormat('MMMM yyyy').format(DateTime(goal.year, goal.month))}';
        break;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: textColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal header
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: textColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      goal.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  Text(
                    currencyFormat.format(goal.amount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Description
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 8),

              // Progress bar
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),

              const SizedBox(height: 8),

              // Progress details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current: ${currencyFormat.format(currentAmount)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    goal.goalType == GoalType.expense && remaining < 0
                        ? 'Over Budget: ${currencyFormat.format(-remaining)}'
                        : 'Remaining: ${currencyFormat.format(remaining)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _amountController.clear();
    setState(() {
      _selectedGoalType = GoalType.income;
    });
  }

  void _addGoal() async {
    if (_formKey.currentState!.validate()) {
      try {
        final amount = double.parse(_amountController.text);

        final success = await widget.appController.addGoal(
          name: _nameController.text,
          amount: amount,
          goalType: _selectedGoalType,
          year: _selectedYear,
          month: _selectedMonth,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Financial goal added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
          // Refresh the goals list
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add goal. Please try again.'),
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
