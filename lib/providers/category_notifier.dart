import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    final categories = await CategoryService.getCategories();
    state = categories;
  }

  Future<void> addCategory(Category category) async {
    await CategoryService.addCategory(category);
    await loadCategories();
  }

    Future<void> updateCategory(Category category) async {
    await CategoryService.updateCategory(category);
    state = [
    for (final c in state)
      if (c.id == category.id) category else c
  ];
}

  Future<void> deleteCategory(String id) async {
    await CategoryService.deleteCategory(id);
    await loadCategories();
  }
}
