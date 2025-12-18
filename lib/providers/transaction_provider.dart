import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../utils/app_snackbar.dart';
import 'package:flutter/material.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>(
  (ref) => TransactionNotifier(),
);

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final GlobalKey<NavigatorState>? navigatorKey;

  TransactionNotifier({this.navigatorKey}) : super([]) {
    loadTransactions();
  }

  BuildContext? get _context => navigatorKey?.currentContext;

  Future<void> loadTransactions() async {
    try {
      final transactions = await TransactionService.getTransactions();
      state = transactions;
    } catch (e) {
      final ctx = _context;
      if (ctx != null) {
        AppSnackbar.show(ctx,
            message: 'Failed to load transactions', isError: true);
      }
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await TransactionService.addTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      final ctx = _context;
      if (ctx != null) {
        AppSnackbar.show(ctx,
            message: 'Could not add transaction', isError: true);
      }
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await TransactionService.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      final ctx = _context;
      if (ctx != null) {
        AppSnackbar.show(ctx,
            message: 'Could not delete transaction', isError: true);
      }
    }
  }
}