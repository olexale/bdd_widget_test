import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

void main() {
  test("I Don't See Rich Text pre-built step generated", () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I don't see {'0'} rich text
    ''';

    const expectedSteps = '''
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

    final feature = FeatureFile(
      featureDir: '$path.feature',
      package: path,
      input: featureFile,
    );

    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedSteps,
    );
  });
}
