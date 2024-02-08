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
// ignore_for_file: unused_import, directives_ordering

@Tags(['customFeatureTag'])
import 'package:bdd_widget_test/world.dart';
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
    Future<void> bddSetUp(WidgetTester tester, World world) async {
      await theAppIsRunning(tester, world);
    }
    Future<void> bddTearDown(WidgetTester tester, World world) async {
      await _iDoNotSeeText(tester, '42', world);
    }
    Future<void> beforeEach(String title, World world, [List<String>? tags]) async {
      await Hooks.beforeEach(title, world, tags);
    }
    Future<void> afterEach(String title, bool success, World world, [List<String>? tags]) async {
      await Hooks.afterEach(title, success, world, tags);
    }
    customTestWidgets(\'\'\'Initial counter value is 0\'\'\', (tester) async {
      final World world = World.empty();
      bool success = true;
      try {
        await beforeEach(\'\'\'Initial counter value is 0\'\'\', world, ['customScenarioTag']);
        await bddSetUp(tester, world);
        await theAppIsRunning(tester, world);
        await iRunCode(tester, 'func foo() {}; func bar() { print("hey!"); };', world);
        await iSeeText(tester, '0', world);
      } on TestFailure {
        success = false;
        rethrow;
      } finally {
        await bddTearDown(tester, world);
        await afterEach(
          \'\'\'Initial counter value is 0\'\'\',
          success,
          world,
          ['customScenarioTag'],
        );
      }
    }, tags: ['customScenarioTag']);
  });
  group(\'\'\'Counter 2\'\'\', () {
    Future<void> bddSetUp(WidgetTester tester, World world) async {
      await theAppIsRunning(tester, world);
    }
    Future<void> beforeEach(String title, World world, [List<String>? tags]) async {
      await Hooks.beforeEach(title, world, tags);
    }
    Future<void> afterEach(String title, bool success, World world, [List<String>? tags]) async {
      await Hooks.afterEach(title, success, world, tags);
    }
    customTestWidgets(\'\'\'Initial counter value is 0\'\'\', (tester) async {
      final World world = World.empty();
      bool success = true;
      try {
        await beforeEach(\'\'\'Initial counter value is 0\'\'\', world);
        await bddSetUp(tester, world);
        await theAppIsRunning(tester, world);
      } on TestFailure {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          \'\'\'Initial counter value is 0\'\'\',
          success,
          world,
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
        addWorld: true,
      ),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
