import 'package:hive/hive.dart';
import '../models/category.dart';

class CategoryService{
  static const String boxName = "categories";

  static Future<Box<Category>> openBox() async {
    try {
      return await Hive.openBox<Category>(boxName);
    } catch (e) {
      // If there's a corruption error when opening the box, delete and recreate it
      print('Error opening category box: \$e');
      await Hive.deleteBoxFromDisk(boxName);
      return await Hive.openBox<Category>(boxName);
    }
  }

  static Future<List<Category>> getCategories() async {
    try {
      final box = await openBox();
      return box.values.whereType<Category>().toList();
    } catch (e) {
      // If there's a type error, clear the box and return empty list
      print('Error loading categories: \$e');
      final box = await Hive.openBox<Category>(boxName);
      await box.clear();
      return [];
    }
  }

  static Future<void> addCategory(Category category) async {
    try {
      final box = await openBox();
      await box.put(category.id, category);
    } catch (e) {
      // If there's a type error, clear the box and retry
      print('Error adding category: \$e');
      final box = await Hive.openBox<Category>(boxName);
      await box.clear();
      await box.put(category.id, category);
    }
  }

  static Future<void> updateCategory(Category category) async {
    try {
      final box = await openBox();
      await box.put(category.id, category);
    } catch (e) {
      // If there's a type error, clear the box and retry
      print('Error updating category: \$e');
      final box = await Hive.openBox<Category>(boxName);
      await box.clear();
      await box.put(category.id, category);
    }
  }

  static Future<void> deleteCategory(String id) async {
    try {
      final box = await openBox();
      await box.delete(id);
    } catch (e) {
      // If there's a type error, clear the box
      print('Error deleting category: \$e');
      final box = await Hive.openBox<Category>(boxName);
      await box.clear();
    }
  }
}
