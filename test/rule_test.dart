import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

void main() {
  test('Rule becomes a nested group with its own background', () {
    const featureFile = '''
Feature: Testing feature
  Rule: Testing rule
    Background:
      Given the app is running
    Scenario: Testing scenario
      Then I see {'0'} text
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';
import './step/i_see_text.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    group(\'\'\'Testing rule\'\'\', () {
      Future<void> bddRuleSetUp(WidgetTester tester) async {
        await theAppIsRunning(tester);
      }
      testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
        await bddRuleSetUp(tester);
        await iSeeText(tester, '0');
      });
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

  test('A rule background applies only to its own scenarios', () {
    const featureFile = '''
Feature: Testing feature
  Background:
    Given the app is running
  Scenario: Outside the rule
    Then I see {'9'} text
  Rule: Rule A
    Background:
      Given I wait
    Scenario: Inside rule A
      Then I see {'0'} text
  Rule: Rule B
    Scenario: Inside rule B
      Then I see {'1'} text
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';
import './step/i_see_text.dart';
import './step/i_wait.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsRunning(tester);
    }
    testWidgets(\'\'\'Outside the rule\'\'\', (tester) async {
      await bddSetUp(tester);
      await iSeeText(tester, '9');
    });
    group(\'\'\'Rule A\'\'\', () {
      Future<void> bddRuleSetUp(WidgetTester tester) async {
        await iWait(tester);
      }
      testWidgets(\'\'\'Inside rule A\'\'\', (tester) async {
        await bddSetUp(tester);
        await bddRuleSetUp(tester);
        await iSeeText(tester, '0');
      });
    });
    group(\'\'\'Rule B\'\'\', () {
      testWidgets(\'\'\'Inside rule B\'\'\', (tester) async {
        await bddSetUp(tester);
        await iSeeText(tester, '1');
      });
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

  test('Rule tags are inherited by the scenarios inside it', () {
    const featureFile = '''
Feature: Testing feature
  @smoke
  Rule: Tagged rule
    @fast
    Scenario: Testing scenario
      Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    group(\'\'\'Tagged rule\'\'\', () {
      testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
        await theAppIsRunning(tester);
      }, tags: ['smoke', 'fast']);
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

  test('After: applies to scenarios inside a rule', () {
    const featureFile = '''
Feature: Testing feature
  Rule: Testing rule
    Scenario: Testing scenario
      Given the app is running
  After:
    Then I clean up
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_clean_up.dart';
import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddTearDown(WidgetTester tester) async {
      await iCleanUp(tester);
    }
    group(\'\'\'Testing rule\'\'\', () {
      testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
        try {
          await theAppIsRunning(tester);
        } finally {
          await bddTearDown(tester);
        }
      });
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
}
