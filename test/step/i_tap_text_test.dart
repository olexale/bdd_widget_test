import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

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

/// Example: When I tap {'some'} text
Future<void> iTapText(
  WidgetTester tester,
  String text,
) async {
  await tester.tap(find.text(text));
  await tester.pump();
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
