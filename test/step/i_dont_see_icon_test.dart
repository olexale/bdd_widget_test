import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("I Don't See Icon pre-built step generated", () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I don't see {Icons.add} icon
    ''';

    const expectedSteps = '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I don't see {Icons.add} icon
Future<void> iDontSeeIcon(
  WidgetTester tester,
  IconData icon,
) async {
  expect(find.byIcon(icon), findsNothing);
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
