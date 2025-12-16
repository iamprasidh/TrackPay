import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction_provider.dart';
import '../../models/transaction.dart';
import '../../models/transaction_type.dart';

final totalIncomeProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);

  return transactions
      .where((t) => t.transactionType == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalExpenseProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);

  return transactions
      .where((t) => t.transactionType == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);
});

final balanceProvider = Provider<double>((ref) {
  final income = ref.watch(totalIncomeProvider);
  final expense = ref.watch(totalExpenseProvider);

  return income - expense;
});

final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionProvider);

  return transactions
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
});
