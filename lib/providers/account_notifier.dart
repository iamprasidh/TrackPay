import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/account.dart';
import '../services/account_service.dart';

class AccountNotifier extends StateNotifier<List<Account>>{
  AccountNotifier() :super([]) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final account = await AccountServices.getAccounts();
    state = account;
  }

  Future<void> addAccounts(Account account) async {
    await AccountServices.addAccount(account);
    await loadAccounts();
  }

  Future <void> deleteAccount(String id) async {
    await AccountServices.deleteAccount(id);
    await loadAccounts();
  }
}