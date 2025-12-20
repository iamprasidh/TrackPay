import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:trackpay/models/account.dart';
import 'package:trackpay/models/budget.dart';
import 'package:trackpay/models/category.dart';
import 'package:trackpay/models/transaction.dart';
import 'package:trackpay/models/transaction_type.dart';
import 'package:trackpay/services/account_service.dart';
import 'package:trackpay/services/budget_service.dart';
import 'package:trackpay/services/category_service.dart';
import 'package:trackpay/services/transaction_service.dart';
import 'package:trackpay/utils/csv_utils.dart';
import 'package:trackpay/utils/list_extensions.dart';

class BackupService {
  static Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final base = Directory('${dir.path}/TrackPay/backups');
    if (!await base.exists()) {
      await base.create(recursive: true);
    }
    return base;
  }

  static String _timestamp() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }

  static Future<Directory> _createBackupDir() async {
    final base = await _baseDir();
    final name = 'backup_${_timestamp()}';
    final dir = Directory('${base.path}/$name');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<List<Directory>> listBackups() async {
    final base = await _baseDir();
    final entries = base.listSync().whereType<Directory>().toList();
    entries.sort((a, b) => b.path.compareTo(a.path));
    return entries;
  }

  static Future<String> exportAllToCsv() async {
    final dir = await _createBackupDir();

    final accounts = await AccountService.getAccounts();
    final categories = await CategoryService.getCategories();
    final budgets = await BudgetService.getBudgets();
    final transactions = await TransactionService.getTransactions();

    final accountsRows = <List<String>>[
      ['id', 'account_name', 'opening_balance'],
      ...accounts.map(
        (a) => [a.id, a.accountName, a.openingBalance.toString()],
      ),
    ];

    final categoriesRows = <List<String>>[
      ['id', 'category_name', 'sub_categories'],
      ...categories.map(
        (c) => [c.id, c.categoryName, c.subCategories.join('|')],
      ),
    ];

    final budgetsRows = <List<String>>[
      ['id', 'category_id', 'limit', 'start_date', 'end_date'],
      ...budgets.map(
        (b) => [
          b.id,
          b.categoryId,
          b.limit.toString(),
          b.startDate?.toIso8601String() ?? '',
          b.endDate?.toIso8601String() ?? '',
        ],
      ),
    ];

    final transactionsRows = <List<String>>[
      [
        'id',
        'date',
        'account_id',
        'category_id',
        'type',
        'amount',
        'sub_category_name',
        'note',
      ],
      ...transactions.map(
        (t) => [
          t.id,
          t.date.toIso8601String(),
          t.accountId,
          t.categoryId,
          t.transactionType.name,
          t.amount.toString(),
          t.subCategoryName ?? '',
          t.note ?? '',
        ],
      ),
    ];

    await File(
      '${dir.path}/accounts.csv',
    ).writeAsBytes(CsvUtils.toUtf8WithBom(CsvUtils.encode(accountsRows)));
    await File(
      '${dir.path}/categories.csv',
    ).writeAsBytes(CsvUtils.toUtf8WithBom(CsvUtils.encode(categoriesRows)));
    await File(
      '${dir.path}/budgets.csv',
    ).writeAsBytes(CsvUtils.toUtf8WithBom(CsvUtils.encode(budgetsRows)));
    await File(
      '${dir.path}/transactions.csv',
    ).writeAsBytes(CsvUtils.toUtf8WithBom(CsvUtils.encode(transactionsRows)));

    return dir.path;
  }

  static Future<void> importAllFromCsv({
    Directory? sourceDir,
    bool clearExisting = true,
  }) async {
    final dir =
        sourceDir ??
        (await listBackups()).firstOrNull ??
        await _createBackupDir();

    final accountsFile = File('${dir.path}/accounts.csv');
    final categoriesFile = File('${dir.path}/categories.csv');
    final budgetsFile = File('${dir.path}/budgets.csv');
    final transactionsFile = File('${dir.path}/transactions.csv');

    if (!await accountsFile.exists() ||
        !await categoriesFile.exists() ||
        !await budgetsFile.exists() ||
        !await transactionsFile.exists()) {
      throw Exception('Missing CSV files in ${dir.path}');
    }

    final accountsBox = await AccountService.openBox();
    final categoriesBox = await CategoryService.openBox();
    final budgetsBox = await BudgetService.openBox();
    final transactionsBox = await TransactionService.openBox();

    if (clearExisting) {
      await accountsBox.clear();
      await categoriesBox.clear();
      await budgetsBox.clear();
      await transactionsBox.clear();
    }

    final accountsCsv = await accountsFile.readAsString();
    final categoriesCsv = await categoriesFile.readAsString();
    final budgetsCsv = await budgetsFile.readAsString();
    final transactionsCsv = await transactionsFile.readAsString();

    List<List<String>> accRows = CsvUtils.decode(accountsCsv);
    List<List<String>> catRows = CsvUtils.decode(categoriesCsv);
    List<List<String>> budRows = CsvUtils.decode(budgetsCsv);
    List<List<String>> txnRows = CsvUtils.decode(transactionsCsv);

    if (accRows.isNotEmpty) accRows = accRows.skip(1).toList();
    if (catRows.isNotEmpty) catRows = catRows.skip(1).toList();
    if (budRows.isNotEmpty) budRows = budRows.skip(1).toList();
    if (txnRows.isNotEmpty) txnRows = txnRows.skip(1).toList();

    for (final r in accRows) {
      if (r.length < 3) continue;
      final id = r[0];
      final name = r[1];
      final opening = double.tryParse(r[2]) ?? 0.0;
      final a = Account(id: id, accountName: name, openingBalance: opening);
      await accountsBox.put(id, a);
    }

    for (final r in catRows) {
      if (r.length < 3) continue;
      final id = r[0];
      final name = r[1];
      final subs = r[2].isEmpty ? <String>[] : r[2].split('|');
      final c = Category(id: id, categoryName: name, subCategories: subs);
      await categoriesBox.put(id, c);
    }

    for (final r in budRows) {
      if (r.length < 5) continue;
      final id = r[0];
      final categoryId = r[1];
      final limit = double.tryParse(r[2]) ?? 0.0;
      final start = r[3].isEmpty ? null : DateTime.tryParse(r[3]);
      final end = r[4].isEmpty ? null : DateTime.tryParse(r[4]);
      final b = Budget(
        id: id,
        categoryId: categoryId,
        limit: limit,
        startDate: start,
        endDate: end,
      );
      await budgetsBox.put(id, b);
    }

    for (final r in txnRows) {
      if (r.length < 8) continue;
      final id = r[0];
      final date = DateTime.tryParse(r[1]) ?? DateTime.now();
      final accountId = r[2];
      final categoryId = r[3];
      final type = r[4].toLowerCase() == 'income'
          ? TransactionType.income
          : TransactionType.expense;
      final amount = double.tryParse(r[5]) ?? 0.0;
      final sub = r[6].isEmpty ? null : r[6];
      final note = r[7].isEmpty ? null : r[7];
      final t = Transaction(
        id: id,
        date: date,
        transactionType: type,
        amount: amount,
        accountId: accountId,
        categoryId: categoryId,
        subCategoryName: sub,
        note: note,
      );
      await transactionsBox.put(id, t);
    }
  }
}
