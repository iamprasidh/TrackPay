import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context, ref),
          ),
        ],
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                'No categories yet.\nTap the + button to add some!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category, context, ref);
              },
            ),
    );
  }

  Widget _buildCategoryCard(Category category, BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main category header
            Row(
              children: [
                const Icon(Icons.category, size: 24, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.categoryName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _showEditCategoryDialog(context, ref, category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _deleteCategory(context, ref, category.id),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Subcategories tree visualization
            if (category.subCategories.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subcategories:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...category.subCategories.map((subcategory) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 36, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subcategory,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.red),
                            onPressed: () => _removeSubcategory(context, ref, category, subcategory),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            
            const SizedBox(height: 8),
            
            // Add subcategory button
            TextButton(
              onPressed: () => _showAddSubcategoryDialog(context, ref, category),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16),
                  SizedBox(width: 4),
                  Text('Add Subcategory'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final newCategory = Category(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  categoryName: name,
                  subCategories: [],
                );
                ref.read(categoryNotifierProvider.notifier).addCategory(newCategory);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, Category category) {
    final controller = TextEditingController(text: category.categoryName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final updatedCategory = Category(
                  id: category.id,
                  categoryName: name,
                  subCategories: category.subCategories,
                );
                ref.read(categoryNotifierProvider.notifier).updateCategory(updatedCategory);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddSubcategoryDialog(BuildContext context, WidgetRef ref, Category category) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Subcategory to ${category.categoryName}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subcategory Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final updatedSubcategories = List<String>.from(category.subCategories)..add(name);
                final updatedCategory = Category(
                  id: category.id,
                  categoryName: category.categoryName,
                  subCategories: updatedSubcategories,
                );
                ref.read(categoryNotifierProvider.notifier).updateCategory(updatedCategory);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeSubcategory(BuildContext context, WidgetRef ref, Category category, String subcategory) {
    final updatedSubcategories = List<String>.from(category.subCategories)..remove(subcategory);
    final updatedCategory = Category(
      id: category.id,
      categoryName: category.categoryName,
      subCategories: updatedSubcategories,
    );
    ref.read(categoryNotifierProvider.notifier).updateCategory(updatedCategory);
  }

  void _deleteCategory(BuildContext context, WidgetRef ref, String categoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(categoryNotifierProvider.notifier).deleteCategory(categoryId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}