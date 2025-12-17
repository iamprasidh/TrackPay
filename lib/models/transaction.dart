import 'package:hive/hive.dart';
import 'transaction_type.dart';

part 'transaction.g.dart';

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
  final String? subCategoryName;

  @HiveField(7)
  final String? note;

  
  Transaction({
    required this.id,
    required this.date,
    required this.transactionType,
    required this.amount,
    required this.accountId,
    required this.categoryId,
    this.subCategoryName,
    this.note,
  });
}