import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'package:trackpay/services/account_service.dart';
import 'package:trackpay/services/category_service.dart';
import 'package:trackpay/services/budget_service.dart';
import 'package:trackpay/services/transaction_service.dart';
import 'package:trackpay/models/transaction_type.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:permission_handler/permission_handler.dart';

class ExportService {
  static Future<Directory> _targetDownloadsDir() async {
    if (Platform.isAndroid) {
      final dirs = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      final dir = dirs != null && dirs.isNotEmpty
          ? dirs.first
          : await getApplicationDocumentsDirectory();
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final d = await getDownloadsDirectory();
      final dir = d ?? await getApplicationDocumentsDirectory();
      if (!await dir.exists()) await dir.create(recursive: true);
      return dir;
    }
    final dir = await getApplicationDocumentsDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static String _timestamp() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }

  static Future<String> _saveToCommonDownloadsAndroid({
    required String baseName,
    required String ext,
    required Uint8List bytes,
    required MimeType mimeType,
  }) async {
    try {
      final savedPath = await FileSaver.instance.saveFile(
        name: baseName,
        ext: ext,
        bytes: bytes,
        mimeType: mimeType,
      );
      if (savedPath != null && !savedPath.contains('/Android/')) {
        return savedPath;
      }
    } catch (_) {}
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Storage permission denied');
    }
    final downloadsDir = await DownloadsPathProvider.downloadsDirectory;
    final dir = downloadsDir ?? await _targetDownloadsDir();
    final path = '${dir.path}${Platform.pathSeparator}$baseName.$ext';
    final f = File(path);
    await f.writeAsBytes(bytes, flush: true);
    return path;
  }

  static Future<String> exportExcelToStorage() async {
    final excel = Excel.createExcel();
    final accounts = await AccountService.getAccounts();
    final categories = await CategoryService.getCategories();
    final budgets = await BudgetService.getBudgets();
    final transactions = await TransactionService.getTransactions();

    final shAccounts = excel['Accounts'];
    shAccounts.appendRow(['id', 'account_name', 'opening_balance']);
    for (final a in accounts) {
      shAccounts.appendRow([a.id, a.accountName, a.openingBalance]);
    }

    final shCategories = excel['Categories'];
    shCategories.appendRow(['id', 'category_name', 'sub_categories']);
    for (final c in categories) {
      shCategories.appendRow([c.id, c.categoryName, c.subCategories.join('|')]);
    }

    final shBudgets = excel['Budgets'];
    shBudgets.appendRow([
      'id',
      'category_id',
      'limit',
      'start_date',
      'end_date',
    ]);
    for (final b in budgets) {
      shBudgets.appendRow([
        b.id,
        b.categoryId,
        b.limit,
        b.startDate?.toIso8601String() ?? '',
        b.endDate?.toIso8601String() ?? '',
      ]);
    }

    final shTransactions = excel['Transactions'];
    shTransactions.appendRow([
      'id',
      'date',
      'account_id',
      'category_id',
      'type',
      'amount',
      'sub_category_name',
      'note',
    ]);
    for (final t in transactions) {
      shTransactions.appendRow([
        t.id,
        t.date.toIso8601String(),
        t.accountId,
        t.categoryId,
        t.transactionType == TransactionType.income ? 'income' : 'expense',
        t.amount,
        t.subCategoryName ?? '',
        t.note ?? '',
      ]);
    }

    final bytes = excel.save()!;
    if (Platform.isAndroid) {
      final baseName = 'TrackPay_${_timestamp()}';
      return _saveToCommonDownloadsAndroid(
        baseName: baseName,
        ext: 'xlsx',
        bytes: Uint8List.fromList(bytes),
        mimeType: MimeType.microsoftExcel,
      );
    } else {
      final dir = await _targetDownloadsDir();
      final file = File(
        '${dir.path}${Platform.pathSeparator}TrackPay_${_timestamp()}.xlsx',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    }
  }

  static Future<String> exportPdfToStorage() async {
    final pdf = pw.Document();
    final transactions = await TransactionService.getTransactions();

    final headers = [
      'Date',
      'Type',
      'Amount',
      'Account',
      'Category',
      'Sub',
      'Note',
    ];
    final data = transactions.map((t) {
      return [
        t.date.toIso8601String(),
        t.transactionType == TransactionType.income ? 'income' : 'expense',
        t.amount.toStringAsFixed(2),
        t.accountId,
        t.categoryId,
        t.subCategoryName ?? '',
        t.note ?? '',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: 'TrackPay Transactions'),
          pw.TableHelper.fromTextArray(headers: headers, data: data),
        ],
      ),
    );

    final bytes = await pdf.save();
    if (Platform.isAndroid) {
      final baseName = 'TrackPay_${_timestamp()}';
      return _saveToCommonDownloadsAndroid(
        baseName: baseName,
        ext: 'pdf',
        bytes: Uint8List.fromList(bytes),
        mimeType: MimeType.pdf,
      );
    } else {
      final dir = await _targetDownloadsDir();
      final file = File(
        '${dir.path}${Platform.pathSeparator}TrackPay_${_timestamp()}.pdf',
      );
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    }
  }
}
