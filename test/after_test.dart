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
}
