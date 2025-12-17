import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => CategoryNotifier(),
);

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = await CategoryService.getCategories();
  }

  Future<void> addCategory(Category category) async {
    await CategoryService.addCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await CategoryService.updateCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await CategoryService.deleteCategory(id);
    await loadCategories();
  }
}
