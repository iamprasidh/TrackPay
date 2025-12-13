class Category {
  final String id;
  final String categoryName;
  final String? subCategoryName;

  Category({
    required this.id,
    required this.categoryName,
    this.subCategoryName,
  });
}