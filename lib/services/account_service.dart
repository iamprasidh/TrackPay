import 'package:hive/hive.dart';
import '../models/account.dart';

class AccountService{
  static const String boxName = "accounts";

    static Future<List<Account>> getAccounts() async {
    final box = await Hive.openBox<Account>(boxName);
    return box.values.toList();
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

