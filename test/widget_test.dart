import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bodega_app/main.dart';

void main() {
  testWidgets('BodegaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BodegaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
