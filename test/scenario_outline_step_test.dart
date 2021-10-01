import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Scenario Outline Step', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: eating
    Given there are <start> cucumbers

    Examples:
      | start |
      |    12 |
      |    20 |
''';

    const expectedStep = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> thereAreCucumbers(WidgetTester tester, dynamic param1) async {
  throw UnimplementedError();
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedStep,
    );
  });
}
