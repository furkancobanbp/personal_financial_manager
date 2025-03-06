// lib/views/entry_form_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/app_controller.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class EntryFormView extends StatefulWidget {
  final AppController appController;

  const EntryFormView({Key? key, required this.appController})
    : super(key: key);

  @override
  _EntryFormViewState createState() => _EntryFormViewState();
}

class _EntryFormViewState extends State<EntryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get all categories
    final categories = widget.appController.getAllCategories();

    // Group categories by type
    final incomeCategories =
        categories
            .where((c) => c.type == TransactionType.income)
            .map((c) => c.name)
            .toList();

    final expenseCategories =
        categories
            .where((c) => c.type == TransactionType.expense)
            .map((c) => c.name)
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Enter Transaction Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // Transaction name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Transaction Name',
                hintText: 'e.g., Monthly Salary, Rent Payment',
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
                hintText: 'Amount in Turkish Lira',
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
                ...incomeCategories.map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      '$category (Income)',
                      style: const TextStyle(color: AppColors.incomeTextColor),
                    ),
                  ),
                ),

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
                ...expenseCategories.map(
                  (category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      '$category (Expense)',
                      style: const TextStyle(color: AppColors.expenseTextColor),
                    ),
                  ),
                ),
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
                    onPressed: _addTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Add Transaction'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
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
    setState(() {
      _selectedCategory = null;
      _selectedDate = DateTime.now();
    });
  }

  void _addTransaction() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      try {
        final amount = double.parse(_amountController.text);

        final success = await widget.appController.addTransaction(
          name: _nameController.text,
          amount: amount,
          categoryName: _selectedCategory!,
          date: _selectedDate,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add transaction. Please try again.'),
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
