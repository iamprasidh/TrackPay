import 'package:hive/hive.dart';
import '../models/account.dart';

class CategoryServices{
  static const String boxName = "categories";

  static Future<Box<Account>> openBox() async {
    return await Hive.openBox<Account>(boxName);
  }

  static Future<void> addCategory(Account category) async {
    final box = await openBox();
    await box.put(category.id, category);
  }

  static Future<void> updateCategory(Account category) async {
    final box = await openBox();
    await box.put(category.id, category);
  }

  static Future<void> deleteCategory(String id) async {
    final box = await openBox();
    await box.delete(id);
  }
}