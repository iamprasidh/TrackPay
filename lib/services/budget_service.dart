import 'package:hive/hive.dart';
import '../models/budget.dart';

class BudgetService {
  static const String boxName = "budgets";

  static Future<Box<Budget>> openBox() async {
    return await Hive.openBox<Budget>(boxName);
  }

static Future<List<Budget>> getBudgets() async {
    try {
      final box = await openBox();
      return box.values.whereType<Budget>().toList();
    } catch (e) {
      // If there's a type error, clear the box and return empty list
      print('Error loading budgets: $e');
      final box = await Hive.openBox<Budget>(boxName);
      await box.clear();
      return [];
    }
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

