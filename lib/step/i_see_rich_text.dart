import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: When I see {'text'} rich text
Future<void> iSeeRichText(
  WidgetTester tester,
  String text,
) async {
  final finder = find.byWidgetPredicate(
    (widget) => widget is RichText && widget.text.toPlainText() == text,
  );
  expect(finder, findsOneWidget);
}
