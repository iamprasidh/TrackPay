import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpay/utils/csv_utils.dart';

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
}
