import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpay/models/transaction_type.dart';

import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/list_extensions.dart';
import '../../utils/app_colors.dart';
import '../transactions/add_transaction_screen.dart';
import '../settings/settings_screen.dart';
import 'analytics_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  static const List<String> _monthNames = <String>[
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

  void _prevMonth() {
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final isBeforeOrEqualCurrent =
        selectedMonth.year < now.year ||
        (selectedMonth.year == now.year && selectedMonth.month < now.month);
    if (!isBeforeOrEqualCurrent) return;
    setState(() {
      selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final allTransactions = ref.watch(transactionProvider);
    final monthlyTransactions = allTransactions
        .where(
          (t) =>
              t.date.year == selectedMonth.year &&
              t.date.month == selectedMonth.month,
        )
        .toList();
    final monthlyIncome = monthlyTransactions
        .where((t) => t.transactionType == TransactionType.income)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    final monthlyExpense = monthlyTransactions
        .where((t) => t.transactionType == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    final monthlyNet = monthlyIncome - monthlyExpense;
    final now = DateTime.now();
    final isCurrentMonth =
        selectedMonth.year == now.year && selectedMonth.month == now.month;
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [const SizedBox(width: 5), const Text('TrackPay')],
        ),
        centerTitle: false,
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
            // Month selector and monthly summary
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: _prevMonth,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    onPressed: () {
                      final now = DateTime.now();
                      final isCurrentMonth =
                          selectedMonth.year == now.year &&
                          selectedMonth.month == now.month;
                      if (!isCurrentMonth) _nextMonth();
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Builder(
                builder: (context) {
                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AnalyticsScreen(
                                      initialMonth: selectedMonth,
                                      filterType: TransactionType.income,
                                    ),
                                  ),
                                );
                              },
                              child: ClipPath(
                                clipper: _NotchedRectClipper(
                                  side: _NotchSide.right,
                                  notchRadius: 26,
                                  cornerRadius: 16,
                                ),
                                child: _StatTile(
                                  title: "Income",
                                  value: formatCurrency(monthlyIncome),
                                  icon: Icons.trending_up_rounded,
                                  color:
                                      Theme.of(
                                        context,
                                      ).extension<AppColors>()?.income ??
                                      Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 0),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AnalyticsScreen(
                                      initialMonth: selectedMonth,
                                      filterType: TransactionType.expense,
                                    ),
                                  ),
                                );
                              },
                              child: ClipPath(
                                clipper: _NotchedRectClipper(
                                  side: _NotchSide.left,
                                  notchRadius: 26,
                                  cornerRadius: 16,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: _StatTile(
                                    title: "Expense",
                                    value: formatCurrency(monthlyExpense),
                                    icon: Icons.trending_down_rounded,
                                    color:
                                        Theme.of(
                                          context,
                                        ).extension<AppColors>()?.expense ??
                                        Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Center circular analytics button overlapping tiles
                      Material(
                        color: Theme.of(context).colorScheme.primary,
                        shape: const CircleBorder(),
                        elevation: 3,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AnalyticsScreen(
                                  initialMonth: selectedMonth,
                                  filterType: null,
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.insights_outlined,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Add Transaction button above closing balance section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Transaction'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Closing Balance",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    formatCurrency(monthlyNet),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: monthlyTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isCurrentMonth
                                ? "No transactions yet"
                                : "No transactions",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (isCurrentMonth) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AddTransactionScreen(),
                                  ),
                                );
                              },
                              child: const Text('Add your first transaction'),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: monthlyTransactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final t = monthlyTransactions[index];
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
                        final subCategory = t.subCategoryName;
                        final categoryPath = [
                          if (categoryName != null) categoryName,
                          if (subCategory != null && subCategory.isNotEmpty)
                            subCategory,
                        ].join(' > ');
                        final formattedDate =
                            '${t.date.day.toString().padLeft(2, '0')} '
                            '${_monthNames[t.date.month - 1]} '
                            '${t.date.year}';

                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isIncome
                                  ? (Theme.of(
                                              context,
                                            ).extension<AppColors>()?.income ??
                                            Theme.of(
                                              context,
                                            ).colorScheme.tertiary)
                                        .withOpacity(0.15)
                                  : (Theme.of(
                                              context,
                                            ).extension<AppColors>()?.expense ??
                                            Theme.of(context).colorScheme.error)
                                        .withOpacity(0.15),
                              child: Icon(
                                isIncome
                                    ? Icons.trending_up_rounded
                                    : Icons.trending_down_rounded,
                                color: isIncome
                                    ? (Theme.of(
                                            context,
                                          ).extension<AppColors>()?.income ??
                                          Theme.of(
                                            context,
                                          ).colorScheme.tertiary)
                                    : (Theme.of(
                                            context,
                                          ).extension<AppColors>()?.expense ??
                                          Theme.of(context).colorScheme.error),
                              ),
                            ),
                            title: Text(
                              displayAmount,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isIncome
                                    ? (Theme.of(
                                            context,
                                          ).extension<AppColors>()?.income ??
                                          Theme.of(
                                            context,
                                          ).colorScheme.tertiary)
                                    : (Theme.of(
                                            context,
                                          ).extension<AppColors>()?.expense ??
                                          Theme.of(context).colorScheme.error),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (categoryPath.isNotEmpty)
                                  Text(
                                    categoryPath,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                if (t.note != null && t.note!.isNotEmpty)
                                  Text(t.note!),
                                Text(
                                  [
                                    if (accountName != null) accountName,
                                    formattedDate,
                                  ].join(' • '),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
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
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color:
                                                  Theme.of(context)
                                                      .extension<AppColors>()
                                                      ?.expense ??
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.error,
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
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit, size: 18),
                                      const SizedBox(width: 8),
                                      const Text('Edit'),
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
                                        color:
                                            Theme.of(
                                              context,
                                            ).extension<AppColors>()?.expense ??
                                            Theme.of(context).colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('Delete'),
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
      // Floating action button removed; Add Transaction button is placed above closing balance
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

enum _NotchSide { left, right }

class _NotchedRectClipper extends CustomClipper<Path> {
  final _NotchSide side;
  final double notchRadius;
  final double cornerRadius;

  _NotchedRectClipper({
    required this.side,
    required this.notchRadius,
    this.cornerRadius = 16,
  });

  @override
  Path getClip(Size size) {
    final rectPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        ),
      );

    final centerY = size.height / 2;
    final centerX = side == _NotchSide.left ? 0.0 : size.width;

    final circlePath = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: notchRadius),
      );

    return Path.combine(PathOperation.difference, rectPath, circlePath);
  }

  @override
  bool shouldReclip(covariant _NotchedRectClipper oldClipper) {
    return oldClipper.side != side ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.cornerRadius != cornerRadius;
  }
}
