import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../transaction_provider.dart';
import '../../models/transaction.dart';
import '../account_provider.dart';

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
  final accounts = ref.watch(accountNotifierProvider); // all accounts
  final transactions = ref.watch(transactionProvider);

  final income = transactions
      .where((t) => t.transactionType == TransactionType.income)
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  final expense = transactions
      .where((t) => t.transactionType == TransactionType.expense)
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  final totalAccountBalance = accounts.fold<double>(
      0.0, (sum, a) => sum + a.openingBalance);

  return totalAccountBalance + income - expense;
});

final recentTransactionsProvider = Provider<List<Transaction>>((ref) {
  final transactions = ref.watch(transactionProvider);

  return transactions
      .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
});
