import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../services/account_service.dart';

final accountProvider = FutureProvider<List<Account>>((ref) async {
  return AccountService.getAccounts();
});