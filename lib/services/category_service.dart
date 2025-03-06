// lib/services/category_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class Category {
  final String name;
  final TransactionType type;

  Category({required this.name, required this.type});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      type: json['type'] == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
    );
  }
}

class CategoryService extends ChangeNotifier {
  List<Category> _categories = [];
  
  List<Category> get categories => List.unmodifiable(_categories);

  // Load categories from storage
  Future<void> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('categories') ?? '[]';
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      _categories = jsonList.map((json) => Category.fromJson(json)).toList();
      
      // Add default categories if none exist
      if (_categories.isEmpty) {
        _addDefaultCategories();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading categories: $e');
      _categories = [];
      _addDefaultCategories();
    }
  }

  // Save categories to storage
  Future<void> saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_categories.map((c) => c.toJson()).toList());
    await prefs.setString('categories', jsonString);
  }

  // Add default categories
  void _addDefaultCategories() {
    final defaults = [
      Category(name: "Salary", type: TransactionType.income),
      Category(name: "Bank Loan", type: TransactionType.expense),
      Category(name: "Debt to Person", type: TransactionType.expense),
      Category(name: "Parental Expenses", type: TransactionType.expense),
      Category(name: "Credit Card Debt", type: TransactionType.expense),
      Category(name: "Bonus", type: TransactionType.income),
    ];
    
    for (final category in defaults) {
      _categories.add(category);
    }
    
    saveCategories();
  }

  // Add a new category
  Future<bool> addCategory(String name, TransactionType type) async {
    // Check if category already exists
    if (_categories.any((c) => c.name == name)) {
      return false;
    }
    
    _categories.add(Category(name: name, type: type));
    await saveCategories();
    notifyListeners();
    return true;
  }

  // Remove a category
  Future<bool> removeCategory(String name) async {
    final index = _categories.indexWhere((c) => c.name == name);
    if (index >= 0) {
      _categories.removeAt(index);
      await saveCategories();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Update a category
  Future<bool> updateCategory(
    String oldName, 
    String newName, 
    TransactionType type
  ) async {
    // Check if the new name already exists (unless it's the same as old name)
    if (oldName != newName && _categories.any((c) => c.name == newName)) {
      return false;
    }
    
    final index = _categories.indexWhere((c) => c.name == oldName);
    if (index >= 0) {
      _categories[index] = Category(name: newName, type: type);
      await saveCategories();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Get all categories of a specific type
  List<String> getCategoriesByType(TransactionType type) {
    return _categories
        .where((c) => c.type == type)
        .map((c) => c.name)
        .toList();
  }

  // Get the type of a category by name
  TransactionType? getCategoryType(String name) {
    final category = _categories.firstWhere(
      (c) => c.name == name,
      orElse: () => Category(name: '', type: TransactionType.expense),
    );
    return category.name.isEmpty ? null : category.type;
  }
}