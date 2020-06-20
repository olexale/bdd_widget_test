import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('I See Text pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I see {0} text
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> ISeeText(WidgetTester tester, String text) async {
  expect(find.text(text), findsOneWidget);
}
''';

    final feature =
        FeatureFile(path: '$path.feature', package: path, input: featureFile);

    expect(feature.getStepFiles().single.dartContent, expectedSteps);
  });
}
