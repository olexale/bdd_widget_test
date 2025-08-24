import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

void main() {
  test('I Tap Icon pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I tap {Icons.add} icon
    ''';

    const expectedSteps = '''
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: When I tap {Icons.add} icon
Future<void> iTapIcon(
  WidgetTester tester,
  IconData icon,
) async {
  await tester.tap(find.byIcon(icon));
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
