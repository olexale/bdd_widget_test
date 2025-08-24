import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

void main() {
  test('I See Multple Texts pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I see multiple {'text'} texts
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

/// Example: When I see multiple {'text'} texts
Future<void> iSeeMultipleTexts(
  WidgetTester tester,
  String text,
) async {
  expect(find.text(text), findsWidgets);
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
