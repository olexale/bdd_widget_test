import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

void main() {
  test('Scenario Outline', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: eating
    Given there are <start> cucumbers
    When I eat <eat> cucumbers
    Then I should have <left> cucumbers

    Examples:
      | start | eat | left |
      |    12 |   5 |    7 |
      |    20 |   5 |   15 |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/there_are_cucumbers.dart';
import './step/i_eat_cucumbers.dart';
import './step/i_should_have_cucumbers.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Outline: eating (12, 5, 7)\'\'\', (tester) async {
      await thereAreCucumbers(tester, 12);
      await iEatCucumbers(tester, 5);
      await iShouldHaveCucumbers(tester, 7);
    });
    testWidgets(\'\'\'Outline: eating (20, 5, 15)\'\'\', (tester) async {
      await thereAreCucumbers(tester, 20);
      await iEatCucumbers(tester, 5);
      await iShouldHaveCucumbers(tester, 15);
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

  test('Scenario Outline Parameters', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: params
    Given there are mixed <int> <String> <Custom> parameters

    Scenarios:
      | int   | String  | Custom     |
      |  12   |   '5'   |  Icons.add |
      |  '20' |   5.0   |   MyClass  |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/there_are_mixed_parameters.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Outline: params (12, '5', Icons.add)\'\'\', (tester) async {
      await thereAreMixedParameters(tester, 12, '5', Icons.add);
    });
    testWidgets(\'\'\'Outline: params ('20', 5.0, MyClass)\'\'\', (tester) async {
      await thereAreMixedParameters(tester, '20', 5.0, MyClass);
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
