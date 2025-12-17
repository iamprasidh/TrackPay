import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../services/account_service.dart';

class AccountNotifier extends StateNotifier<List<Account>>{
  AccountNotifier() :super([]) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    final accounts = await AccountService.getAccounts();
    state = accounts;
  }

  Future<void> addAccounts(Account account) async {
    await AccountService.addAccount(account);
    await loadAccounts();
  }

  Future<void> updateAccount(Account account) async {
    await AccountService.updateAccount(account);
    await loadAccounts();
  }

  Future <void> deleteAccount(String id) async {
    await AccountService.deleteAccount(id);
    await loadAccounts();
  }
}