import 'package:hive/hive.dart';
import 'package:trackpay/models/transaction.dart';

class TransactionService {
  static const String boxName = "transactions";

  static Future<Box<Transaction>> openBox() async {
    return await Hive.openBox<Transaction>(boxName);
  }

  static Future<List<Transaction>> getTransactions() async {
  final box = await openBox();
  return box.values.toList();
}

  static Future<void> addTransaction(Transaction transaction) async {
    final box = await openBox();
    await box.put(transaction.id, transaction);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final box = await openBox();
    await box.put(transaction.id, transaction);
  }

  static Future<void> deletetransaction(String id) async {
    final box = await openBox();
    await box.delete(id);
  }

}