import 'package:bdd_widget_test/src/step/bdd_step.dart';

class IEnterIntoInputField implements BddStep {
  @override
  String get content => '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: When I enter {'text'} into {1} input field
Future<void> iEnterIntoInputField(
  WidgetTester tester,
  String text,
  int index,
) async {
  final textField = find.byType(TextField).at(index);

  await tester.enterText(textField, text);
}
''';
}
