import 'package:hive/hive.dart';
import '../models/budget.dart';

class BudgetServices {
  static const String boxName = "budgets";

  static Future<Box<Budget>> openbox() async {
    return await Hive.openBox<Budget>(boxName);
  }

  static Future<void> addBudget(Budget budget) async {
    final box = await openbox();
    await box.put(budget.id, budget);
  }

  static Future<void> updateBudget(Budget budget) async {
    final box = await openbox();
    await box.put(budget.id, budget);
  }

  static Future<void> deleteBudget(String id) async {
    final box = await openbox();
    await box.delete(id);
  }
}

