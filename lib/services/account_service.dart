import 'package:hive/hive.dart';
import '../models/account.dart';

class AccountService{
  static const String boxName = "accounts";

    static Future<List<Account>> getAccounts() async {
    try {
      final box = await Hive.openBox<Account>(boxName);
      return box.values.whereType<Account>().toList();
    } catch (e) {
      // If there's a type error, clear the box and return empty list
      print('Error loading accounts: $e');
      final box = await Hive.openBox<Account>(boxName);
      await box.clear();
      return [];
    }
  }

  static Future<Box<Account>> openBox() async {
    return await Hive.openBox<Account>(boxName);
  }

  static Future<void> addAccount(Account account) async {
    final box = await openBox();
    await box.put(account.id, account);
  }

  static Future<void> updateAccount(Account account) async {
    final box = await openBox();
    await box.put(account.id, account);
  }

  static Future<void> deleteAccount(String id) async {
    final box = await openBox();
    await box.delete(id);
  }
}

