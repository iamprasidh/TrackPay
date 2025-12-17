import 'package:hive/hive.dart';
import 'package:trackpay/models/transaction.dart';

class TransactionService {
  static const String boxName = "transactions";

  static Future<Box<Transaction>> openBox() async {
    return await Hive.openBox<Transaction>(boxName);
  }

  static Future<List<Transaction>> getTransactions() async {
    try {
      final box = await Hive.openBox<Transaction>(boxName);
      return box.values.whereType<Transaction>().toList();
    } catch (e) {
      // If there's a type error, clear the box and return empty list
      print('Error loading transactions: $e');
      final box = await Hive.openBox<Transaction>(boxName);
      await box.clear();
      return [];
    }
  }

  static Future<void> addTransaction(Transaction transaction) async {
    final box = await openBox();
    await box.put(transaction.id, transaction);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final box = await openBox();
    await box.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    final box = await openBox();
    await box.delete(id);
  }

}