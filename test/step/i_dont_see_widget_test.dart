import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

void main() {
  test("I Don't See Widget pre-built step generated", () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I don't see {SomeWidget} widget
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I don't see {SomeWidget} widget
Future<void> iDontSeeWidget(
  WidgetTester tester,
  Type type,
) async {
  expect(find.byType(type), findsNothing);
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
