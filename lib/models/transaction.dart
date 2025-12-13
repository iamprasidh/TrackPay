enum TransactionType { income, expense }

class Transaction {
  final String id;
  final DateTime date;
  final String accountId;    
  final String categoryId;
  final TransactionType transactionType;
  final double amount;
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
