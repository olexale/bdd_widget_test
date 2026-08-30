import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

import 'util/testing_data.dart';

void main() {
  const expectedComment = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

''';
  const expectedImports = '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

''';
  const expectedHeader = '''$expectedComment$expectedImports''';

  test('Empty feature file', () {
    const expectedFeatureDart =
        '''
$expectedComment$expectedImports
void main() {
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: '',
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('simplest feature file parses', () {
    const expectedFeatureDart =
        '''
${expectedHeader}import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: minimalFeatureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('Step with parameters', () {
    const expectedFeatureDart =
        '''
${expectedHeader}import './step/the_app_is_running.dart';
import './step/i_see_text.dart';
import './step/i_see_icon.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
      await iSeeText(tester, 'nice param');
      await iSeeIcon(tester, Icons.add);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('Several features in one file', () {
    const expectedFeatureDart =
        '''
$expectedComment// some comment

${expectedImports}import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'First testing feature\'\'\', () {
    testWidgets(\'\'\'First testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
    });
  });
  group(\'\'\'Second testing feature\'\'\', () {
    testWidgets(\'\'\'First testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
    });
    testWidgets(\'\'\'Second testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: bigFeatureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('Feature with special characters in names', () {
    const expectedFeatureDart =
        '''
$expectedComment// some comment

${expectedImports}import './step/the_app_is_running.dart';
import './step/i_see_text.dart';

void main() {
  group(\'\'\'"Testing" <Special> {Characters}\'\'\', () {
    testWidgets(\'\'\'Test's "special" characters\'\'\', (tester) async {
      await theAppIsRunning(tester);
      await iSeeText(tester, 'test');
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: '''
// some comment

Feature: "Testing" <Special> {Characters}
  Scenario: Test's "special" characters
    Given the app is running
    Then I see {'test'} text
''',
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('Feature with very long step description', () {
    const expectedFeatureDart =
        '''
${expectedHeader}import './step/the_app_is_running.dart';
import './step/i_verify_that_this_is_a_very_long_step_description_that_tests_whether_the_framework_can_handle_extremely_long_step_names_without_issues.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
      await iVerifyThatThisIsAVeryLongStepDescriptionThatTestsWhetherTheFrameworkCanHandleExtremelyLongStepNamesWithoutIssues(tester);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
    Then I verify that this is a very long step description that tests whether the framework can handle extremely long step names without issues
''',
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('Multiple scenarios in single feature', () {
    const expectedFeatureDart =
        '''
${expectedHeader}import './step/the_app_is_running.dart';
import './step/i_see_text.dart';
import './step/i_tap_icon.dart';

void main() {
  group(\'\'\'Login feature\'\'\', () {
    testWidgets(\'\'\'Successful login\'\'\', (tester) async {
      await theAppIsRunning(tester);
      await iSeeText(tester, 'Login');
    });
    testWidgets(\'\'\'Failed login\'\'\', (tester) async {
      await theAppIsRunning(tester);
      await iSeeText(tester, 'Error');
    });
    testWidgets(\'\'\'Logout\'\'\', (tester) async {
      await iTapIcon(tester, Icons.logout);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: '''
Feature: Login feature
  Scenario: Successful login
    Given the app is running
    Then I see {'Login'} text

  Scenario: Failed login
    Given the app is running
    Then I see {'Error'} text

  Scenario: Logout
    When I tap {Icons.logout} icon
''',
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
