import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class BudgetNotifier extends StateNotifier<List<Budget>> {
  BudgetNotifier() : super([]) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    final budgets = await BudgetService.getBudgets();
    state = budgets;
  }

  Future<void> addBudget(Budget budget) async {
    await BudgetService.addBudget(budget);
    await loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await BudgetService.deleteBudget(id);
    await loadBudgets();
  }
}
