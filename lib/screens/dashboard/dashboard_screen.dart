import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpay/models/transaction_type.dart';

import '../../providers/dashboard/dashboard_provider.dart';
import '../transactions/add_transaction_screen.dart'; 

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackPay'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 TOP ANALYTICS
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatTile(
                  title: "Balance",
                  value:
                      "₹${ref.watch(balanceProvider).toStringAsFixed(2)}",
                ),
                _StatTile(
                  title: "Income",
                  value:
                      "₹${ref.watch(totalIncomeProvider).toStringAsFixed(2)}",
                ),
                _StatTile(
                  title: "Expense",
                  value:
                      "₹${ref.watch(totalExpenseProvider).toStringAsFixed(2)}",
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 TRANSACTIONS LIST
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: transactions.isEmpty
                ? const Center(child: Text("No transactions yet"))
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final t = transactions[index];
                      return ListTile(
                        title: Text(
                          "₹${t.amount}",
                          style: TextStyle(
                            color: t.transactionType ==
                                    TransactionType.income
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        subtitle: Text(t.note ?? ''),
                        trailing: Text(
                          t.transactionType ==
                                  TransactionType.income
                              ? "Income"
                              : "Expense",
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
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

  const _StatTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
