import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

void main() {
  test('The screen matches golden pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Then the screen matches golden {'home'}
    ''';

    const expectedSteps = r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: Then the screen matches golden {'home'}
///
/// The path is resolved relative to the generated `*_test.dart` file, so in a
/// feature file in `test/` this step compares with `test/goldens/home.png`.
Future<void> theScreenMatchesGolden(
  WidgetTester tester,
  String name,
) async {
  await expectLater(
    find.byType(WidgetsApp),
    matchesGoldenFile('goldens/$name.png'),
  );
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
