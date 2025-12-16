import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpay/models/transaction_type.dart';
import 'package:trackpay/providers/transaction_provider.dart';
import '../models/budget.dart';
import 'budget_notifier.dart';
import '../../utils/list_extensions.dart';

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, List<Budget>>(
  (ref) => BudgetNotifier(),
);

final budgetForCategoryProvider =
    Provider.family<double?, String>((ref, categoryId) {
  final budgets = ref.watch(budgetNotifierProvider);

  final budget = budgets.firstOrNull(
    (b) => b.categoryId == categoryId,
  );

  return budget?.limit;
});


final spentPerCategoryProvider =
    Provider.family<double, String>((ref, categoryId) {
  final transactions = ref.watch(transactionProvider);
  return transactions
      .where((t) =>
          t.categoryId == categoryId &&
          t.transactionType == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);
});

final budgetStatusProvider =
    Provider.family<bool, String>((ref, categoryId) {
  final limit = ref.watch(budgetForCategoryProvider(categoryId));
  if (limit == null) return false;

  final spent = ref.watch(spentPerCategoryProvider(categoryId));
  return spent >= limit;
});
