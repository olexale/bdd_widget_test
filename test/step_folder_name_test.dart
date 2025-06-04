import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('relative stepFolderName', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../custom_steps/the_app_is_running.dart';

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
      generatorOptions:
          const GeneratorOptions(stepFolderName: '../../../custom_steps'),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('absolute stepFolderName', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../custom_steps/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test/subdir/feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(stepFolderName: 'custom_steps'),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
  test('step folder is not under test folder', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../custom_steps/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test/subdir/feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(
        stepFolderName: 'custom_steps',
        relativeToTestFolder: false,
      ),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
