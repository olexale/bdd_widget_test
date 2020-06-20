import 'package:bdd_widget_test/src/feature_file.dart';
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

Future<void> IInvokeTest(WidgetTester tester) async {
  throw UnimplementedError();
}
''';

    final feature =
        FeatureFile(path: '$path.feature', package: path, input: featureFile);

    expect(feature.getStepFiles().single.dartContent, expectedSteps);
  });

  test('Generic step with parameters generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I invoke {0} test with {Some} parameter
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> IInvokeTestWithParameter(WidgetTester tester, dynamic param1, dynamic param2) async {
  throw UnimplementedError();
}
''';

    final feature =
        FeatureFile(path: '$path.feature', package: path, input: featureFile);

    expect(feature.getStepFiles().single.dartContent, expectedSteps);
  });

  test('Special characters ignored', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When !  I@ #invoke\$%   ^'`~  &*+=) test ?   &&/| \\ ;:
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> IInvokeTest(WidgetTester tester) async {
  throw UnimplementedError();
}
''';

    final feature =
        FeatureFile(path: '$path.feature', package: path, input: featureFile);

    expect(feature.getStepFiles().single.dartContent, expectedSteps);
  });
}
