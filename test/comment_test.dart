import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

void main() {
  test('Comments above features copy-paste into the target file', () {
    const featureFile = '''
// This is a comment

Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

// This is a comment

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

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
      input: featureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('Gherkin comments are ignored', () {
    const featureFile = '''
# This is a comment

Feature: Testing feature
  #One more comment
  Scenario: Testing scenario
# Another comment
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
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
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

  test('Description lines under a keyword are ignored', () {
    const featureFile = '''
Feature: Testing feature
  This is a description
  Scenario: Testing scenario
    This is a description too
    Given the app is running

Feature: Testing feature 2
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
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
    });
  });
  group(\'\'\'Testing feature 2\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
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

  test('A line that belongs nowhere is reported, not dropped', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running

This line belongs nowhere
''';

    expect(
      () => FeatureFile(
        featureDir: 'test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('test.feature'),
            contains('(5:1)'),
            contains('This line belongs nowhere'),
          ),
        ),
      ),
    );
  });

  test('A mistyped keyword is reported, not dropped', () {
    const featureFile = '''
Feature: Testing feature
  Scenrio: Testing scenario
    Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('(3:1)'),
            contains('Given the app is running'),
            contains('is not part of a scenario'),
          ),
        ),
      ),
    );
  });
}
