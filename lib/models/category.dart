import 'package:hive/hive.dart';
part 'category.g.dart';

@HiveType(typeId: 2)
class Category {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String CategoryName;
  @HiveField(2)
  final String? subCategoryName;

  Category({
    required this.id,
    required this.CategoryName,
    this.subCategoryName,
  });
}