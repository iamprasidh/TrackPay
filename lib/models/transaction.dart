import 'package:hive/hive.dart';
part 'transaction.g.dart';

enum TransactionType { income, expense }

@HiveType(typeId: 4)
class Transaction {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final DateTime date;
  @HiveField(2)
  final String accountId;
  @HiveField(3)    
  final String categoryId;
  @HiveField(4)
  final TransactionType transactionType;
  @HiveField(5)
  final double amount;
  @HiveField(6)
  final String? note;

  Transaction({
    required this.id,
    DateTime? date,
    required this.accountId,
    required this.categoryId,
    required this.transactionType,
    required this.amount,
    this.note,
  }) : date = date ?? DateTime.now();
}
