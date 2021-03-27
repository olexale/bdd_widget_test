import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Then I see exactly widgets pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Then I see exactly {4} {SomeWidget} widgets
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I see exactly {4} {SomeWidget} widgets
Future<void> iSeeExactlyWidgets(
  WidgetTester tester,
  int count,
  Type type,
) async {
  expect(find.byType(type, skipOffstage: false), findsNWidgets(count));
}
''';

    final feature = FeatureFile(
        featureDir: '$path.feature', package: path, input: featureFile);

    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedSteps,
    );
  });
}
