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
import '../../providers/settings_provider.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/list_extensions.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? initialTransaction;
  const AddTransactionScreen({super.key, this.initialTransaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final uuid = const Uuid();

  DateTime selectedDate = DateTime.now();
  TransactionType type = TransactionType.expense;

  Account? selectedAccount;
  String? selectedCategoryId;
  String? selectedSubCategory;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTransaction;
    if (t != null) {
      selectedDate = t.date;
      type = t.transactionType;
      amountController.text = t.amount.toString();
      noteController.text = t.note ?? '';
      selectedCategoryId = t.categoryId;
      selectedSubCategory = t.subCategoryName;

      final accounts = ref.read(accountNotifierProvider);
      selectedAccount = accounts.firstOrNull((a) => a.id == t.accountId);
    }
  }

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

  void _addCategory() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Category"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Category name"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final category = Category(
                id: uuid.v4(),
                categoryName: name,
                subCategories: [],
              );

              await ref
                  .read(categoryNotifierProvider.notifier)
                  .addCategory(category);

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _addSubCategory(Category category) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add subcategory to ${category.categoryName}"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Subcategory name"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final sub = controller.text.trim();
              if (sub.isEmpty) return;

              if (category.subCategories.contains(sub)) {
                Navigator.pop(context);
                return;
              }

              final updated = Category(
                id: category.id,
                categoryName: category.categoryName,
                subCategories: [...category.subCategories, sub],
              );

              await ref
                  .read(categoryNotifierProvider.notifier)
                  .updateCategory(updated);

              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _saveTransaction() async {
    final rawAmount = amountController.text.trim();

    if (rawAmount.isEmpty ||
        selectedAccount == null ||
        selectedCategoryId == null) {
      AppSnackbar.show(
        context,
        message: "Please fill all required fields",
        isError: true,
      );
      return;
    }

    final parsedAmount = double.tryParse(rawAmount);
    if (parsedAmount == null || parsedAmount <= 0) {
      AppSnackbar.show(
        context,
        message: "Enter a valid amount greater than 0",
        isError: true,
      );
      return;
    }

    final category = ref
        .read(categoryNotifierProvider)
        .firstWhere((c) => c.id == selectedCategoryId);

    if (category.subCategories.isNotEmpty && selectedSubCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a subcategory")));
      return;
    }

    final isEditing = widget.initialTransaction != null;
    final transaction = Transaction(
      id: isEditing ? widget.initialTransaction!.id : uuid.v4(),
      date: selectedDate,
      transactionType: type,
      amount: parsedAmount,
      accountId: selectedAccount!.id,
      categoryId: category.id,
      subCategoryName: selectedSubCategory,
      note: noteController.text.trim(),
    );

    try {
      if (isEditing) {
        await ref
            .read(transactionProvider.notifier)
            .updateTransaction(transaction);
      } else {
        await ref
            .read(transactionProvider.notifier)
            .addTransaction(transaction);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: isEditing
            ? "Failed to update transaction. Please try again."
            : "Failed to save transaction. Please try again.",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountNotifierProvider);
    final categories = ref.watch(categoryNotifierProvider);
    final settings = ref.watch(settingsProvider);

    final selectedCategory = selectedCategoryId == null
        ? null
        : categories.firstWhere((c) => c.id == selectedCategoryId);

    final isEditing = widget.initialTransaction != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Transaction" : "Add Transaction"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            /// Expense / Income toggle
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

            /// Date picker
            ListTile(
              title: const Text("Date"),
              subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),

            const SizedBox(height: 16),

            /// Select Account
            DropdownButtonFormField<Account>(
              initialValue: selectedAccount,
              hint: const Text("Select Account"),
              onChanged: (val) => setState(() => selectedAccount = val),
              items: accounts
                  .map(
                    (a) =>
                        DropdownMenuItem(value: a, child: Text(a.accountName)),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// Select Category
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedCategoryId,
                    hint: const Text("Select Category"),
                    onChanged: (val) {
                      setState(() {
                        selectedCategoryId = val;
                        selectedSubCategory = null;
                      });
                    },
                    items: categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.categoryName),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ],
            ),

            if (selectedCategory != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: selectedCategory.subCategories.isNotEmpty
                        ? DropdownButtonFormField<String>(
                            initialValue: selectedSubCategory,
                            hint: const Text("Select Subcategory"),
                            onChanged: (val) =>
                                setState(() => selectedSubCategory = val),
                            items: selectedCategory.subCategories
                                .map(
                                  (sub) => DropdownMenuItem(
                                    value: sub,
                                    child: Text(sub),
                                  ),
                                )
                                .toList(),
                          )
                        : const Text("No subcategories yet"),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addSubCategory(selectedCategory),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            /// Amount
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount"),
            ),

            const SizedBox(height: 16),

            /// Note
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: "Note (optional)"),
            ),

            const SizedBox(height: 32),

            /// Save
            ElevatedButton(
              onPressed: _saveTransaction,
              child:
                  Text(isEditing ? "Update Transaction" : "Save Transaction"),
            ),
          ],
        ),
      ),
    );
  }
}
