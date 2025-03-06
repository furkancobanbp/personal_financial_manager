// lib/views/category_manager_view.dart
import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/transaction.dart';
import '../services/category_service.dart';
import '../utils/constants.dart';

class CategoryManagerView extends StatefulWidget {
  final AppController appController;

  const CategoryManagerView({
    Key? key,
    required this.appController,
  }) : super(key: key);

  @override
  _CategoryManagerViewState createState() => _CategoryManagerViewState();
}

class _CategoryManagerViewState extends State<CategoryManagerView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  TransactionType _selectedType = TransactionType.income;
  Category? _editingCategory;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.appController.getAllCategories();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories table
          Expanded(
            flex: 2,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Existing Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Categories table
                    Expanded(
                      child: ListView.separated(
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isIncome = category.type == TransactionType.income;
                          
                          return ListTile(
                            title: Text(category.name),
                            subtitle: Text(
                              isIncome ? 'Income' : 'Expense',
                              style: TextStyle(
                                color: isIncome 
                                    ? AppColors.incomeTextColor 
                                    : AppColors.expenseTextColor,
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: isIncome 
                                  ? AppColors.incomeBackgroundColor 
                                  : AppColors.expenseBackgroundColor,
                              child: Icon(
                                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isIncome 
                                    ? AppColors.incomeTextColor 
                                    : AppColors.expenseTextColor,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editCategory(category),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _confirmDeleteCategory(category),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Add/Edit form
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
                      Text(
                        _editingCategory == null ? 'Add New Category' : 'Edit Category',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Category name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Category type
                      DropdownButtonFormField<TransactionType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Category Type',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: TransactionType.income,
                            child: Text(
                              'Income',
                              style: TextStyle(color: AppColors.incomeTextColor),
                            ),
                          ),
                          DropdownMenuItem(
                            value: TransactionType.expense,
                            child: Text(
                              'Expense',
                              style: TextStyle(color: AppColors.expenseTextColor),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _cancelEdit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveCategory,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(_editingCategory == null ? 'Add Category' : 'Update Category'),
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

  void _editCategory(Category category) {
    setState(() {
      _editingCategory = category;
      _nameController.text = category.name;
      _selectedType = category.type;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingCategory = null;
      _nameController.clear();
      _selectedType = TransactionType.income;
    });
  }

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      try {
        bool success;
        
        if (_editingCategory == null) {
          // Add new category
          success = await widget.appController.addCategory(
            _nameController.text,
            _selectedType,
          );
        } else {
          // Update existing category
          success = await widget.appController.updateCategory(
            _editingCategory!.name,
            _nameController.text,
            _selectedType,
          );
        }
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _editingCategory == null
                    ? 'Category added successfully!'
                    : 'Category updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _cancelEdit();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save category. It may already exist.'),
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

  void _confirmDeleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the category "${category.name}"?\n\n'
          'This will not affect existing transactions with this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCategory(category);
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category category) async {
    try {
      final success = await widget.appController.removeCategory(category.name);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${category.name}" deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete category "${category.name}".'),
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