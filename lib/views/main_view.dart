// lib/views/main_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';
import '../services/financial_goal_service.dart';
import '../services/forecast_service.dart';
import 'dashboard_view.dart';
import 'transaction_list_view.dart';
import 'goals_view.dart';
import 'forecast_view.dart';
import 'entry_form_view.dart';
import 'category_manager_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;
  late AppController _appController;
  final List<String> _titles = [
    'Dashboard',
    'Transactions',
    'Financial Goals',
    'Forecasts',
    'Add Transaction',
    'Manage Categories',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize services data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryService = Provider.of<CategoryService>(context, listen: false);
      final transactionService = Provider.of<TransactionService>(context, listen: false);
      final goalService = Provider.of<FinancialGoalService>(context, listen: false);
      final forecastService = Provider.of<ForecastService>(context, listen: false);
      
      categoryService.loadCategories();
      transactionService.loadTransactions();
      goalService.loadGoals();
      forecastService.loadForecasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create app controller
    _appController = AppController(
      transactionService: Provider.of<TransactionService>(context),
      categoryService: Provider.of<CategoryService>(context),
      goalService: Provider.of<FinancialGoalService>(context),
      forecastService: Provider.of<ForecastService>(context),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surface,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list),
                label: Text('Transactions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.flag),
                label: Text('Goals'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.trending_up),
                label: Text('Forecasts'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text('Add Transaction'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category),
                label: Text('Categories'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildSelectedPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return DashboardView(appController: _appController);
      case 1:
        return TransactionListView(appController: _appController);
      case 2:
        return GoalsView(appController: _appController);
      case 3:
        return ForecastView(appController: _appController);
      case 4:
        return EntryFormView(appController: _appController);
      case 5:
        return CategoryManagerView(appController: _appController);
      default:
        return const Center(child: Text('Page not found'));
    }
  }
}