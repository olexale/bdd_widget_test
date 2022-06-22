import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('testMethodName test ', () {
    const featureFile = '''
Feature: Counter
    Background:
        Given the app is running
    After:
        And _I do not see {'42'} text
    Scenario: Initial counter value is 0
        Given the app is running
        And I run {'func foo() {}; func bar() { print("hey!"); };'} code
        Then I see {'0'} text
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';
import './step/_i_do_not_see_text.dart';
import './step/i_run_code.dart';
import 'package:bdd_sample/i_see_text.dart';

void main() {
  Future<void> bddSetUp(WidgetTester tester) async {
    await theAppIsRunning(tester);
  }
  Future<void> bddTearDown(WidgetTester tester) async {
    await _iDoNotSeeText(tester, '42');
  }
  group(\'\'\'Counter\'\'\', () {
    customTestWidgets(\'\'\'Initial counter value is 0\'\'\', (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iRunCode(tester, 'func foo() {}; func bar() { print("hey!"); };');
        await iSeeText(tester, '0');
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(
          testMethodName: 'customTestWidgets',
          externalSteps: [
            'package:bdd_sample/i_see_text.dart',
            'package:bdd_sample/i_see_some_text.dart',
            'package:bdd_sample/i_see_some_other_text.dart',
          ]),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
