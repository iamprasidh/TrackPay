import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'category_notifier.dart';

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, List<Category>>(
  (ref) => CategoryNotifier(),
);
