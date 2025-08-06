import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fully custom test ', () {
    const featureFile = '''
@customFeatureTag
Feature: Counter
    Background:
        Given the app is running
    After:
        And _I do not see {'42'} text

    @customScenarioTag
    Scenario: Initial counter value is 0
        Given the app is running
        And I run {'func foo() {}; func bar() { print("hey!"); };'} code
        Then I see {'0'} text
Feature: Counter 2
    Background:
        Given the app is running
    Scenario: Initial counter value is 0
        Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['customFeatureTag'])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './hooksFolder/hooks.dart';
import '../../my_steps/the_app_is_running.dart';
import '../../my_steps/_i_do_not_see_text.dart';
import '../../my_steps/i_run_code.dart';
import 'package:bdd_sample/i_see_text.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group(\'\'\'Counter\'\'\', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsRunning(tester);
    }
    Future<void> bddTearDown(WidgetTester tester) async {
      await _iDoNotSeeText(tester, '42');
    }
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }
    Future<void> afterEach(String title, bool success, [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }
    customTestWidgets(\'\'\'Initial counter value is 0\'\'\', (tester) async {
      var success = true;
      try {
        await beforeEach(\'\'\'Initial counter value is 0\'\'\' , ['customScenarioTag']);
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iRunCode(tester, 'func foo() {}; func bar() { print("hey!"); };');
        await iSeeText(tester, '0');
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await bddTearDown(tester);
        await afterEach(
          \'\'\'Initial counter value is 0\'\'\',
          success,
          ['customScenarioTag'],
        );
      }
    }, tags: ['customScenarioTag']);
  });
  group(\'\'\'Counter 2\'\'\', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsRunning(tester);
    }
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }
    Future<void> afterEach(String title, bool success, [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }
    customTestWidgets(\'\'\'Initial counter value is 0\'\'\', (tester) async {
      var success = true;
      try {
      await beforeEach(\'\'\'Initial counter value is 0\'\'\' );
      await bddSetUp(tester);
      await theAppIsRunning(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          \'\'\'Initial counter value is 0\'\'\',
          success,
        );
      }
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test/sub-feature/feature',
      package: 'bdd_feature',
      input: featureFile,
      generatorOptions: const GeneratorOptions(
        stepFolderName: 'my_steps',
        testMethodName: 'customTestWidgets',
        externalSteps: [
          'package:bdd_sample/i_see_text.dart',
          'package:bdd_sample/i_see_some_text.dart',
          'package:bdd_sample/i_see_some_other_text.dart',
        ],
        addHooks: true,
        hookFolderName: './hooksFolder',
      ),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
