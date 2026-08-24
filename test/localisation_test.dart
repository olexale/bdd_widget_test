import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

void main() {
  test('A localised scenario outline expands per example row', () {
    const featureFile = '''
# language: uk
Функціонал: Лічильник

  Структура сценарію: підрахунок
    Тоді I see <result> text

    Приклади:
      | result |
      | '1'    |
      | '2'    |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_see_text.dart';

void main() {
  group(\'\'\'Лічильник\'\'\', () {
    testWidgets(\'\'\'підрахунок ('1')\'\'\', (tester) async {
      await iSeeText(tester, '1');
    });
    testWidgets(\'\'\'підрахунок ('2')\'\'\', (tester) async {
      await iSeeText(tester, '2');
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

  test('An unknown language is reported', () {
    const featureFile = '''
# language: zz
Feature: Testing feature
  Scenario: Testing scenario
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
          contains('Language not supported: zz'),
        ),
      ),
    );
  });
}
