class Budget {
  final String id;
  final String categoryId; 
  final double limit;      
  final DateTime? startDate; 
  final DateTime? endDate;   

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    this.startDate,
    this.endDate,
  });
}
