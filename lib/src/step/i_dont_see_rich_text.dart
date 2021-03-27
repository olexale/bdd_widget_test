import 'package:bdd_widget_test/src/step/bdd_step.dart';

class IDontSeeRichText implements BddStep {
  @override
  String get content => '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: When I don't see {'text'} rich text
Future<void> iDontSeeRichText(
  WidgetTester tester,
  String text,
) async {
  final finder = find.byWidgetPredicate(
      (widget) => widget is RichText && widget.text.toPlainText() == text);
  expect(finder, findsNothing);
}
''';
}
