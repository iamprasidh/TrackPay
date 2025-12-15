import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget.dart';
import 'budget_notifier.dart';

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, List<Budget>>(
  (ref) => BudgetNotifier(),
);
