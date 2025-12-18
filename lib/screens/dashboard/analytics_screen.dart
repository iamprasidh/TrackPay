import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/transaction_type.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final next = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (!next.isAfter(currentMonth)) {
      setState(() {
        _selectedMonth = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final categories = ref.watch(categoryNotifierProvider);
    final settings = ref.watch(settingsProvider);

    final monthStart = DateTime(_selectedMonth.year, _selectedMonth.month);
    final nextMonthStart =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1);

    final monthTransactions = transactions.where((t) {
      final date = t.date;
      final isOnOrAfterStart = !date.isBefore(monthStart);
      final isBeforeNextMonth = date.isBefore(nextMonthStart);
      return isOnOrAfterStart && isBeforeNextMonth;
    }).toList();

    double monthIncome = 0;
    double monthExpense = 0;
    for (final t in monthTransactions) {
      if (t.transactionType == TransactionType.income) {
        monthIncome += t.amount;
      } else if (t.transactionType == TransactionType.expense) {
        monthExpense += t.amount;
      }
    }

    final categoryById = {for (final c in categories) c.id: c};

    final Map<String, double> expenseByCategory = {};
    for (final t in monthTransactions) {
      if (t.transactionType != TransactionType.expense) continue;
      expenseByCategory.update(t.categoryId, (value) => value + t.amount,
          ifAbsent: () => t.amount);
    }

    final totalExpenseForShare =
        expenseByCategory.values.fold<double>(0, (s, v) => s + v);

    String formatCurrency(double value) {
      final code = settings.currency.isNotEmpty ? settings.currency : 'INR';
      final symbol = switch (code.toUpperCase()) {
        'INR' => '₹',
        'USD' => '\$',
        'EUR' => '€',
        'GBP' => '£',
        _ => '$code ',
      };
      return '$symbol${value.toStringAsFixed(2)}';
    }

    String monthLabel(DateTime date) {
      const monthNames = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${monthNames[date.month - 1]} ${date.year}';
    }

    Widget buildSummaryCards() {
      final colorScheme = Theme.of(context).colorScheme;
      return Row(
        children: [
          Expanded(
            child: _SummaryTile(
              title: 'Income',
              value: formatCurrency(monthIncome),
              color: Colors.green,
              icon: Icons.trending_up_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryTile(
              title: 'Expense',
              value: formatCurrency(monthExpense),
              color: Colors.redAccent,
              icon: Icons.trending_down_rounded,
            ),
          ),
        ],
      );
    }

    Widget buildCategoryBreakdown() {
      if (expenseByCategory.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No expenses for this month yet',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      final entries = expenseByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return Column(
        children: entries.map((entry) {
          final cat = categoryById[entry.key];
          final name = cat?.categoryName ?? 'Unknown';
          final amount = entry.value;
          final share = totalExpenseForShare == 0
              ? 0.0
              : (amount / totalExpenseForShare).clamp(0.0, 1.0);
          final percentage = totalExpenseForShare == 0
              ? 0
              : ((amount / totalExpenseForShare) * 100).round();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatCurrency(amount),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: share,
                    minHeight: 8,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$percentage%',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    Widget buildMonthlyTrend() {
      final now = DateTime.now();
      final List<_MonthStat> lastSixMonths = [];

      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i);
        final start = DateTime(date.year, date.month);
        final end = DateTime(date.year, date.month + 1);

        double monthExpenseTotal = 0;
        for (final t in transactions) {
          final d = t.date;
          if (!d.isBefore(start) && d.isBefore(end)) {
            if (t.transactionType == TransactionType.expense) {
              monthExpenseTotal += t.amount;
            }
          }
        }

        lastSixMonths.add(
          _MonthStat(
            label: monthLabel(date),
            totalExpense: monthExpenseTotal,
          ),
        );
      }

      final maxExpense = lastSixMonths
          .fold<double>(0, (max, s) => s.totalExpense > max ? s.totalExpense : max);

      if (maxExpense == 0) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No spending trend yet. Start adding expenses!',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }

      return Column(
        children: lastSixMonths.map((stat) {
          final barValue = (stat.totalExpense / maxExpense).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    stat.label,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: barValue,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatCurrency(stat.totalExpense),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: _goToPreviousMonth,
                    ),
                    Column(
                      children: [
                        Text(
                          monthLabel(_selectedMonth),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Overview of your spending and income',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: _goToNextMonth,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildSummaryCards(),
                const SizedBox(height: 24),
                Text(
                  'Spending by category',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: buildCategoryBreakdown(),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Spending trend (last 6 months)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: buildMonthlyTrend(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 10),
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

class _MonthStat {
  final String label;
  final double totalExpense;

  _MonthStat({required this.label, required this.totalExpense});
}