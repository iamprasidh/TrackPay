import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../models/account.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TransactionType? type = TransactionType.expense;
  Account? selectedAccount;
  Category? selectedCategory;

  final uuid = const Uuid();

  void _saveTransaction() async {
    if (amountController.text.isEmpty || selectedAccount == null || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final transaction = Transaction(
      id: uuid.v4(),
      date: selectedDate,
      transactionType: type!,
      amount: double.tryParse(amountController.text) ?? 0,
      accountId: selectedAccount!.id,
      categoryId: selectedCategory!.id,
      note: noteController.text,
    );

    await ref.read(transactionProvider.notifier).addTransaction(transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountNotifierProvider);
    final categories = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 16),

            // Type
            DropdownButton<TransactionType>(
              value: type,
              onChanged: (val) => setState(() => type = val),
              items: TransactionType.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Account
            DropdownButton<Account>(
              value: selectedAccount,
              hint: const Text("Select Account"),
              onChanged: (val) => setState(() => selectedAccount = val),
              items: accounts
                  .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text(a.accountName),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Category
            DropdownButton<Category>(
              value: selectedCategory,
              hint: const Text("Select Category"),
              onChanged: (val) => setState(() => selectedCategory = val),
              items: categories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.categoryName),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Note
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Note (optional)"),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text("Save Transaction"),
            )
          ],
        ),
      ),
    );
  }
}
