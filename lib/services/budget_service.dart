import 'package:hive/hive.dart';
import '../models/budget.dart';

class BudgetService {
  static const String boxName = "budgets";

  static Future<Box<Budget>> openBox() async {
    return await Hive.openBox<Budget>(boxName);
  }

static Future<List<Budget>> getBudgets() async {
  final box = await openBox();
  return box.values.toList();
}


  static Future<void> addBudget(Budget budget) async {
    final box = await openBox();
    await box.put(budget.id, budget);
  }

  static Future<void> updateBudget(Budget budget) async {
    final box = await openBox();
    await box.put(budget.id, budget);
  }

  static Future<void> deleteBudget(String id) async {
    final box = await openBox();
    await box.delete(id);
  }
}

