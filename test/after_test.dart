import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

void main() {
  test('After steps appear after groups ', () {
    const featureFile = '''
Feature: Testing feature
  After:
    And the test finishes
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_test_finishes.dart';
import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddTearDown(WidgetTester tester) async {
      await theTestFinishes(tester);
    }
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      try {
        await theAppIsRunning(tester);
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
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  // `After:` is rewritten into a scenario before parsing, so it needs a
  // scenario keyword to rewrite into. A file of outlines titles nothing with
  // `Scenario:`, and falls back to the dialect's own first keyword.
  test('After: applies to a feature written in outlines only', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Testing scenario
    Given the app is running

    Examples:
      | a |
      | 1 |
  After:
    And the test finishes
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_test_finishes.dart';
import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddTearDown(WidgetTester tester) async {
      await theTestFinishes(tester);
    }
    testWidgets(\'\'\'Testing scenario (1)\'\'\', (tester) async {
      try {
        await theAppIsRunning(tester);
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
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  // `After:` is rewritten into a scenario, and Gherkin allows no background
  // after a scenario, so the block is parsed apart from the rest of the
  // feature — wherever it is written, it is not in a background's way.
  test('After: may be written above Background:', () {
    const featureFile = '''
Feature: Testing feature
  After:
    Then I clean up

  Background:
    Given I am logged in

  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_am_logged_in.dart';
import './step/i_clean_up.dart';
import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await iAmLoggedIn(tester);
    }
    Future<void> bddTearDown(WidgetTester tester) async {
      await iCleanUp(tester);
    }
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
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
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('After: may be written above a rule Background:', () {
    const featureFile = '''
Feature: Testing feature
  Rule: Testing rule
    After:
      Then I clean up

    Background:
      Given I am logged in

    Scenario: Testing scenario
      Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(
      feature.dartContent,
      allOf(
        contains('await iCleanUp(tester);'),
        contains('await iAmLoggedIn(tester);'),
        contains('await theAppIsRunning(tester);'),
      ),
    );
  });

  // A doc string holds text, not keywords: a `@` or a `Scenario:` inside one
  // does not end the `After:` block it belongs to.
  test('A doc string inside After: does not end the block', () {
    const featureFile = '''
Feature: Testing feature
  After:
    Given the log reads
      """
      @override
      Scenario: not a scenario
      """
    Then I clean up

  Background:
    Given I am logged in

  Scenario: Testing scenario
    Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(
      feature.dartContent,
      allOf(
        contains('await theLogReads(tester);'),
        contains('await iCleanUp(tester);'),
        isNot(contains('not a scenario')),
      ),
    );
  });

  test('An error inside After: is reported at its line in the file', () {
    const featureFile = '''
Feature: Testing feature
  Background:
    Given I am logged in

  Scenario: Testing scenario
    Given the app is running

  After:
    Then I clean up
    This line belongs nowhere
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('test/test.feature'),
            contains('(10:5)'),
            contains('This line belongs nowhere'),
          ),
        ),
      ),
    );
  });
}
