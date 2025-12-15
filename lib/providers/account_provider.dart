import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import 'account_notifier.dart';

final accountNotifierProvider =
    StateNotifierProvider<AccountNotifier, List<Account>>(
  (ref) => AccountNotifier(),
);
