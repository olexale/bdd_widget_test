import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dismiss the page pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Then dismiss the page
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> dismissThePage(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}
''';

    final feature =
        FeatureFile(path: '$path.feature', package: path, input: featureFile);

    expect(feature.getStepFiles().single.dartContent, expectedSteps);
  });
}
