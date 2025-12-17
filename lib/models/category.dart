import 'package:hive/hive.dart';
part 'category.g.dart';

@HiveType(typeId: 2)
class Category {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String categoryName;
  @HiveField(2)
  final List<String> subCategories; 

  Category({
    required this.id,
    required this.categoryName,
    required this.subCategories,
  });
}