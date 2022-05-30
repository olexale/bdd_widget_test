import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feature testMethodName test ', () {
    const featureFile = '''
@testMethodName: customTestWidgets

Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    customTestWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      try {
        await theAppIsRunning(tester);
      } on Exception catch (error, stackTrace) {
        debugPrint(\'\${error.toString()}: \$stackTrace\');
        rethrow;
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

  test('scenario testMethodName test ', () {
    const featureFile = '''
Feature: Testing feature

  @testMethodName: customTestWidgets
  Scenario: Testing scenario
    Given the app is running
  
  @testMethodName: otherTestWidgets
  Scenario: Testing scenario 2
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    customTestWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      try {
        await theAppIsRunning(tester);
      } on Exception catch (error, stackTrace) {
        debugPrint(\'\${error.toString()}: \$stackTrace\');
        rethrow;
      }
    });
    otherTestWidgets(\'\'\'Testing scenario 2\'\'\', (tester) async {
      try {
        await theAppIsRunning(tester);
      } on Exception catch (error, stackTrace) {
        debugPrint(\'\${error.toString()}: \$stackTrace\');
        rethrow;
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
