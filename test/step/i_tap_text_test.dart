import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('I Tap Text pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I tap {foo} text
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> iTapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}
''';

    final feature =
        FeatureFile(path: '$path.feature', package: path, input: featureFile);

    expect(feature.getStepFiles().single.dartContent, expectedSteps);
  });
}
