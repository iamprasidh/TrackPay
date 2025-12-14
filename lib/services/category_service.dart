import 'package:hive/hive.dart';
import '../models/category.dart';

class CategoryService{
  static const String boxName = "categories";

  static Future<Box<Category>> openBox() async {
    return await Hive.openBox<Category>(boxName);
  }

  static Future<List<Category>> getCategories() async {
  final box = await openBox();
  return box.values.toList();
}

  static Future<void> addCategory(Category category) async {
    final box = await openBox();
    await box.put(category.id, category);
  }

  static Future<void> updateCategory(Category category) async {
    final box = await openBox();
    await box.put(category.id, category);
  }

  static Future<void> deleteCategory(String id) async {
    final box = await openBox();
    await box.delete(id);
  }
}