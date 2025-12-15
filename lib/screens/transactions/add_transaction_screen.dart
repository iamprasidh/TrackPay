import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../models/transaction.dart';
import '../../providers/account_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  TransactionType _type = TransactionType.expense;
  String? _selectedAccountId;
  String? _selectedCategoryId;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountNotifierProvider);
    final categories = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Income / Expense toggle
              ToggleButtons(
                isSelected: [
                  _type == TransactionType.expense,
                  _type == TransactionType.income,
                ],
                onPressed: (index) {
                  setState(() {
                    _type = index == 0
                        ? TransactionType.expense
                        : TransactionType.income;
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Expense'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Income'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Account dropdown
              DropdownButtonFormField<String>(
                value: _selectedAccountId,
                decoration:
                    const InputDecoration(labelText: 'Account'),
                items: accounts
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.accountName),
                        ))
                    .toList(),
                onChanged: (v) => _selectedAccountId = v,
                validator: (v) =>
                    v == null ? 'Select an account' : null,
              ),

              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration:
                    const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.categoryName),
                        ))
                    .toList(),
                onChanged: (v) => _selectedCategoryId = v,
                validator: (v) =>
                    v == null ? 'Select a category' : null,
              ),

              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration:
                    const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final value = double.tryParse(v ?? '');
                  if (value == null || value <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Note
              TextFormField(
                controller: _noteController,
                decoration:
                    const InputDecoration(labelText: 'Note (optional)'),
              ),

              const SizedBox(height: 24),

              // Save
              ElevatedButton(
                onPressed: _saveTransaction,
                child: const Text('Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    ref.read(transactionNotifierProvider.notifier).addTransaction(
          Transaction(
            id: const Uuid().v4(),
            accountId: _selectedAccountId!,
            categoryId: _selectedCategoryId!,
            transactionType: _type,
            amount: double.parse(_amountController.text),
            note: _noteController.text,
          ),
        );

    Navigator.pop(context);
  }
}
