import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpay/utils/csv_utils.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  testWidgets('App builds simple scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('TrackPay'))),
    );
    expect(find.text('TrackPay'), findsOneWidget);
  });

  group('CsvUtils', () {
    test('encode handles quotes and commas', () {
      final rows = [
        ['id', 'name', 'note'],
        ['1', 'Account "A"', 'Hello, world'],
        ['2', 'Test', 'Multi\nLine'],
      ];
      final csv = CsvUtils.encode(rows);
      expect(
        csv,
        'id,name,note\n1,"Account ""A""","Hello, world"\n2,Test,"Multi\nLine"',
      );
    });

    test('decode parses escaped fields', () {
      final csv = 'a,b,c\n"x","y, z","q""q"';
      final rows = CsvUtils.decode(csv);
      expect(rows.length, 2);
      expect(rows[1], ['x', 'y, z', 'q"q']);
    });
  });

  test('excel workbook creates bytes', () {
    final excel = Excel.createExcel();
    final sh = excel['Sheet1'];
    sh.appendRow(['a', 'b', 'c']);
    final bytes = excel.save();
    expect(bytes, isNotNull);
    expect(bytes!.isNotEmpty, true);
  });

  test('pdf document creates bytes', () async {
    final doc = pw.Document();
    doc.addPage(pw.Page(build: (ctx) => pw.Text('Hello')));
    final bytes = await doc.save();
    expect(bytes.isNotEmpty, true);
  });
}
