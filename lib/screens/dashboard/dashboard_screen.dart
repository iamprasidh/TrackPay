import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpay/models/transaction_type.dart';

import '../../providers/dashboard/dashboard_provider.dart';
import '../transactions/add_transaction_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(recentTransactionsProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackPay'),
        centerTitle: true,
        actions: [
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
                      value:
                          "₹${ref.watch(balanceProvider).toStringAsFixed(2)}",
                      icon: Icons.account_balance_wallet_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      title: "Income",
                      value:
                          "₹${ref.watch(totalIncomeProvider).toStringAsFixed(2)}",
                      icon: Icons.trending_up_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      title: "Expense",
                      value:
                          "₹${ref.watch(totalExpenseProvider).toStringAsFixed(2)}",
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
                        children: const [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("No transactions yet", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        final isIncome = t.transactionType == TransactionType.income;

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (isIncome
                                      ? Colors.greenAccent
                                      : Colors.redAccent)
                                  .withOpacity(0.2),
                              child: Icon(
                                isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                color: isIncome ? Colors.green : Colors.redAccent,
                              ),
                            ),
                            title: Text(
                              "₹${t.amount}",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isIncome ? Colors.green : Colors.redAccent,
                              ),
                            ),
                            subtitle: Text(t.note ?? ''),
                            trailing: Chip(
                              label: Text(isIncome ? 'Income' : 'Expense'),
                              backgroundColor: (isIncome
                                      ? Colors.greenAccent
                                      : Colors.redAccent)
                                  .withOpacity(0.15),
                              labelStyle: TextStyle(
                                color: isIncome ? Colors.green.shade700 : Colors.redAccent,
                                fontWeight: FontWeight.w500,
                              ),
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

  const _StatTile({required this.title, required this.value, this.icon, this.color});

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
