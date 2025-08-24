import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

void main() {
  test('Dismiss the page pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Then I dismiss the page
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I dismiss the page
Future<void> iDismissThePage(
  WidgetTester tester,
) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
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
