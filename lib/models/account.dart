class Account {
  final String id;
  final String accountName;
  final double openingBalance;

  Account({
    required this.id,
    required this.accountName,
    double? openingBalance,   // optional input
  }) : openingBalance = openingBalance ?? 0.0;  // default 0
}
