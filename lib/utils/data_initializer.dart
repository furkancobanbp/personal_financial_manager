// lib/utils/data_initializer.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataInitializer {
  static Future<void> initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // List of data files to initialize
    final dataFiles = [
      {'asset': 'assets/data/finance_data.json', 'key': 'transactions'},
      {'asset': 'assets/data/financial_goals.json', 'key': 'financial_goals'},
      {'asset': 'assets/data/forecast_transactions.json', 'key': 'forecasts'},
      {'asset': 'assets/data/transaction_categories.json', 'key': 'categories'},
    ];
    
    // For each data file, check if data exists in SharedPreferences.
    // If not, load from asset and save to SharedPreferences.
    for (final dataFile in dataFiles) {
      final key = dataFile['key']!;
      
      // Only initialize if data doesn't exist yet
      if (!prefs.containsKey(key)) {
        try {
          // Load data from asset
          final jsonString = await rootBundle.loadString(dataFile['asset']!);
          
          // Save to SharedPreferences
          await prefs.setString(key, jsonString);
          print('Initialized ${dataFile['key']} from asset');
        } catch (e) {
          print('Error initializing ${dataFile['key']}: $e');
        }
      }
    }
  }
}