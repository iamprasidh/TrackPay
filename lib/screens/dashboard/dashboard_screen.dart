import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpay/models/transaction_type.dart';

import '../../providers/dashboard/dashboard_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/list_extensions.dart';
import '../transactions/add_transaction_screen.dart';
import '../settings/settings_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(recentTransactionsProvider);
    final accounts = ref.watch(accountNotifierProvider);
    final categories = ref.watch(categoryNotifierProvider);
    final settings = ref.watch(settingsProvider);

    final colorScheme = Theme.of(context).colorScheme;

    String formatCurrency(double value) {
      String code = settings.currency.isNotEmpty ? settings.currency : 'INR';
      final symbol = switch (code.toUpperCase()) {
        'INR' => '₹',
        'USD' => '\$',
        'EUR' => '€',
        'GBP' => '£',
        _ => '$code ',
      };
      return '$symbol${value.toStringAsFixed(2)}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackPay'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Analytics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      title: "Balance",
                      value: formatCurrency(ref.watch(balanceProvider)),
                      icon: Icons.account_balance_wallet_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      title: "Income",
                      value: formatCurrency(ref.watch(totalIncomeProvider)),
                      icon: Icons.trending_up_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      title: "Expense",
                      value: formatCurrency(ref.watch(totalExpenseProvider)),
                      icon: Icons.trending_down_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                "Recent Transactions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),

            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "No transactions yet",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddTransactionScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add your first transaction'),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        final isIncome =
                            t.transactionType == TransactionType.income;
                        final displayAmount =
                            (isIncome ? '+ ' : '- ') + formatCurrency(t.amount);

                        final accountName = accounts
                            .firstOrNull((a) => a.id == t.accountId)
                            ?.accountName;

                        final categoryName = categories
                            .firstOrNull((c) => c.id == t.categoryId)
                            ?.categoryName;

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  (isIncome
                                          ? Colors.greenAccent
                                          : Colors.redAccent)
                                      .withOpacity(0.2),
                              child: Icon(
                                isIncome
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: isIncome
                                    ? Colors.green
                                    : Colors.redAccent,
                              ),
                            ),
                            title: Text(
                              displayAmount,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isIncome
                                    ? Colors.green
                                    : Colors.redAccent,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (t.note != null && t.note!.isNotEmpty)
                                  Text(t.note!),
                                if (accountName != null || categoryName != null)
                                  Text(
                                    [
                                      if (accountName != null) accountName,
                                      if (categoryName != null) categoryName,
                                    ].join(' • '),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddTransactionScreen(
                                        initialTransaction: t,
                                      ),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Delete transaction?'),
                                      content: const Text(
                                        'This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await ref
                                        .read(transactionProvider.notifier)
                                        .deleteTransaction(t.id);
                                    AppSnackbar.show(
                                      context,
                                      message: 'Transaction deleted',
                                    );
                                  }
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;

  const _StatTile({
    required this.title,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statColor = color ?? cs.primary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: statColor),
            ),
          if (icon != null) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
