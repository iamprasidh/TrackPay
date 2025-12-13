import 'package:hive/hive.dart';
part 'account.g.dart'; 

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String accountName;
  @HiveField(2)
  final double openingBalance;

  Account({
    required this.id,
    required this.accountName,
    double? openingBalance,   // optional input
  }) : openingBalance = openingBalance ?? 0.0;  // default 0
}
