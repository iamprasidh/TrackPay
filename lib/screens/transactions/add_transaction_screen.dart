import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/transaction.dart';
import '../../models/account.dart';
import '../../models/category.dart';
import '../../models/transaction_type.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final uuid = const Uuid();

  DateTime selectedDate = DateTime.now();
  TransactionType type = TransactionType.expense;

  Account? selectedAccount;
  Category? selectedCategory;
  String? selectedSubCategory;

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _addSubCategory(Category category) {
    final TextEditingController subController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add subcategory to ${category.categoryName}"),
        content: TextField(
          controller: subController,
          decoration:
              const InputDecoration(labelText: "Subcategory name"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final sub = subController.text.trim();
              if (sub.isEmpty) return;

              if (category.subCategories.contains(sub)) {
                Navigator.pop(context);
                return;
              }

              final updatedCategory = Category(
                id: category.id,
                categoryName: category.categoryName,
                subCategories: [...category.subCategories, sub],
              );

              await ref
                  .read(categoryNotifierProvider.notifier)
                  .updateCategory(updatedCategory);

              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _saveTransaction() async {
    if (amountController.text.isEmpty ||
        selectedAccount == null ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all required fields")),
      );
      return;
    }

    if (selectedCategory!.subCategories.isNotEmpty &&
        selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select a subcategory")),
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
      subCategoryName: selectedSubCategory,
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
            /// 🔹 Income / Expense toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text("Expense"),
                  selected: type == TransactionType.expense,
                  onSelected: (_) =>
                      setState(() => type = TransactionType.expense),
                ),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text("Income"),
                  selected: type == TransactionType.income,
                  onSelected: (_) =>
                      setState(() => type = TransactionType.income),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 Date
            ListTile(
              title: const Text("Date"),
              subtitle:
                  Text("${selectedDate.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),

            const SizedBox(height: 16),

            /// 🔹 Account
            DropdownButtonFormField<Account>(
              value: selectedAccount,
              hint: const Text("Select Account"),
              onChanged: (val) =>
                  setState(() => selectedAccount = val),
              items: accounts
                  .map((a) => DropdownMenuItem(
                        value: a,
                        child: Text(a.accountName),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// 🔹 Category + Subcategory
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      DropdownButtonFormField<Category>(
                        value: selectedCategory,
                        hint: const Text("Select Category"),
                        onChanged: (val) {
                          setState(() {
                            selectedCategory = val;
                            selectedSubCategory = null;
                          });
                        },
                        items: categories
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.categoryName),
                                ))
                            .toList(),
                      ),

                      const SizedBox(height: 12),

                      if (selectedCategory != null &&
                          selectedCategory!.subCategories.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: selectedSubCategory,
                          hint: const Text("Select Subcategory"),
                          onChanged: (val) => setState(
                              () => selectedSubCategory = val),
                          items: selectedCategory!.subCategories
                              .map((sub) => DropdownMenuItem(
                                    value: sub,
                                    child: Text(sub),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: selectedCategory == null
                      ? null
                      : () => _addSubCategory(selectedCategory!),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 16),

            /// 🔹 Note
            TextField(
              controller: noteController,
              decoration:
                  const InputDecoration(labelText: "Note (optional)"),
            ),

            const SizedBox(height: 32),

            /// 🔹 Save
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text("Save Transaction"),
            ),
          ],
        ),
      ),
    );
  }
}
