import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../utils/app_colors.dart';

import '../../models/account.dart';
import '../../providers/account_provider.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAccountDialog(context, ref),
          ),
        ],
      ),
      body: accounts.isEmpty
          ? Center(
              child: Text(
                'No accounts yet.\nTap the + button to add your first account.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      Icons.account_balance_wallet,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(account.accountName),
                    subtitle: Text(
                      'Balance: ₹${account.openingBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            size: 20,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () => _showEditAccountDialog(context, ref, account),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 20,
                            color: Theme.of(context)
                                    .extension<AppColors>()
                                    ?.expense ??
                                Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _showDeleteConfirmationDialog(context, ref, account),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref) {
    final accountNameController = TextEditingController();
    final balanceController = TextEditingController(text: '0.00');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: accountNameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                hintText: 'e.g., Bank, Cash, Credit Card',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Opening Balance',
                hintText: '0.00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = accountNameController.text.trim();
              final balance = double.tryParse(balanceController.text) ?? 0.0;
              
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an account name')),
                );
                return;
              }

              final newAccount = Account(
                id: const Uuid().v4(),
                accountName: name,
                openingBalance: balance,
              );

              ref.read(accountNotifierProvider.notifier).addAccounts(newAccount);
              Navigator.pop(context);
            },
            child: const Text('Add Account'),
          ),
        ],
      ),
    );
  }

  void _showEditAccountDialog(BuildContext context, WidgetRef ref, Account account) {
    final accountNameController = TextEditingController(text: account.accountName);
    final balanceController = TextEditingController(text: account.openingBalance.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: accountNameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Opening Balance',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = accountNameController.text.trim();
              final balance = double.tryParse(balanceController.text) ?? 0.0;
              
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an account name')),
                );
                return;
              }

              final updatedAccount = Account(
                id: account.id,
                accountName: name,
                openingBalance: balance,
              );

              ref.read(accountNotifierProvider.notifier).updateAccount(updatedAccount);
              Navigator.pop(context);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref, Account account) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${account.accountName}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(accountNotifierProvider.notifier).deleteAccount(account.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}