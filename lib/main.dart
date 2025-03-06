// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/transaction_service.dart';
import 'services/category_service.dart';
import 'services/financial_goal_service.dart';
import 'services/forecast_service.dart';
import 'views/main_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryService()),
        ChangeNotifierProxyProvider<CategoryService, TransactionService>(
          create: (_) => TransactionService(),
          update: (_, categoryService, transactionService) => transactionService!,
        ),
        ChangeNotifierProxyProvider<TransactionService, FinancialGoalService>(
          create: (_) => FinancialGoalService(),
          update: (_, transactionService, goalService) => goalService!,
        ),
        ChangeNotifierProxyProvider2<CategoryService, TransactionService, ForecastService>(
          create: (_) => ForecastService(),
          update: (_, categoryService, transactionService, forecastService) => forecastService!,
        ),
      ],
      child: MaterialApp(
        title: 'Personal Finance Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const MainView(),
      ),
    );
  }
}