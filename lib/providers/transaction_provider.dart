import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:trackpay/providers/transaction_notifier.dart';
import '../models/transaction.dart';
import 'transaction_provider.dart';

final transactionNotifierProvider = 
  StateNotifierProvider<TransactionNotifier, List<Transaction>>(
    (ref) => TransactionNotifier(),
  );