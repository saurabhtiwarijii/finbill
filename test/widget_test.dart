import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finbill/main.dart';

void main() {
  testWidgets('FinBill app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FinBillApp());
    // Verify the app renders without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
