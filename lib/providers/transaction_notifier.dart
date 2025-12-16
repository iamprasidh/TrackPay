import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpay/services/transaction_service.dart';
import '../models/transaction.dart';
import '../services/account_service.dart';

class TransactionNotifier extends StateNotifier<List<Transaction>>{
  TransactionNotifier() : super([]) {
    loadTransaction();
  }

  Future<void> loadTransaction() async {
    final transactions = await TransactionService.getTransactions();
    state = transactions;
  }

   Future<void> addTransaction(Transaction transaction) async {
    await TransactionService.addTransaction(transaction); 
    await loadTransaction();
  }

    Future<void> deleteTransaction(String id) async {
    await TransactionService.deleteTransaction(id); 
    await loadTransaction();
  }
}