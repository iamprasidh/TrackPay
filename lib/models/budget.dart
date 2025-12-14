import 'package:hive/hive.dart';
part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String categoryId; 
  @HiveField(2)
  final double limit;      
  @HiveField(3)
  final DateTime? startDate; 
  @HiveField(4)
  final DateTime? endDate;   

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    this.startDate,
    this.endDate,
  });
}
