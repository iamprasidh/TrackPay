import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpay/models/transaction_type.dart';
import 'package:uuid/uuid.dart';

import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TransactionType type = TransactionType.expense;
  Account? selectedAccount;
  Category? selectedCategory;

  final uuid = const Uuid();

  void _saveTransaction() async {
    if (amountController.text.isEmpty ||
        selectedAccount == null ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final transaction = Transaction(
      id: uuid.v4(),
      date: selectedDate,
      transactionType: type,
      amount: double.tryParse(amountController.text) ?? 0,
      accountId: selectedAccount!.id,
      categoryId: selectedCategory!.id,
      note: noteController.text,
    );

    await ref.read(transactionProvider.notifier).addTransaction(transaction);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _addOrUpdateCategory({Category? existing}) {
    final TextEditingController catController = TextEditingController(
        text: existing != null ? existing.categoryName : '');
    final TextEditingController subCatController = TextEditingController(
        text: existing != null ? existing.subCategoryName ?? '' : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing != null ? "Update Category" : "Add Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: catController,
              decoration: const InputDecoration(labelText: "Category"),
            ),
            TextField(
              controller: subCatController,
              decoration: const InputDecoration(labelText: "Subcategory (optional)"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final id = existing?.id ?? const Uuid().v4();
              final category = Category(
                id: id,
                categoryName: catController.text,
                subCategoryName:
                    subCatController.text.isEmpty ? null : subCatController.text,
              );
              if (existing != null) {
                await ref
                    .read(categoryNotifierProvider.notifier)
                    .updateCategory(category);
              } else {
                await ref
                    .read(categoryNotifierProvider.notifier)
                    .addCategory(category);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("Cancel"))
        ],
      ),
    );
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
            // 🔹 Toggle Expense / Income
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Expense"),
                  selected: type == TransactionType.expense,
                  onSelected: (val) => setState(() => type = TransactionType.expense),
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text("Income"),
                  selected: type == TransactionType.income,
                  onSelected: (val) => setState(() => type = TransactionType.income),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Date Picker
            ListTile(
              title: const Text("Date"),
              subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),

            const SizedBox(height: 16),

            // 🔹 Select Account
            DropdownButtonFormField<Account>(
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

            // 🔹 Select Category & Subcategory
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Category>(
                    value: selectedCategory,
                    hint: const Text("Select Category"),
                    onChanged: (val) => setState(() => selectedCategory = val),
                    items: categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                  "${c.categoryName}${c.subCategoryName != null ? ' > ${c.subCategoryName}' : ''}"),
                            ))
                        .toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addOrUpdateCategory(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 16),

            // 🔹 Note
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
