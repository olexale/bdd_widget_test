import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Generic step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I invoke test
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> iInvokeTest(WidgetTester tester) async {
  throw UnimplementedError();
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

  test('Generic step with parameters generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I invoke {0} test with {Some} parameter and {true} parameter and {'value'} parameter
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> iInvokeTestWithParameterAndParameterAndParameter(WidgetTester tester, num param1, dynamic param2, bool param3, String param4) async {
  throw UnimplementedError();
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

  test('Special characters ignored', () {
    const path = 'test';
    const featureFile = r'''
Feature: Testing feature
    Scenario: Testing scenario
        When !  I@ #invoke$%   ^'`~  &*+=) test ?   &&/| \ ;:
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> iInvokeTest(WidgetTester tester) async {
  throw UnimplementedError();
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
