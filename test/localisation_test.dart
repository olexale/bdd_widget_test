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

  test('After: works in a localised feature', () {
    const featureFile = '''
# language: fr
Fonctionnalité: Testing feature
  Scénario: Testing scenario
    Soit the app is running
  After:
    Alors I clean up
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
  // scenario keyword to rewrite into, and Gherkin accepts only the dialect's
  // own. A localised file written in outlines titles nothing with a plain
  // scenario keyword, so the rewrite falls back to the dialect's first one.
  test('After: works in a localised feature written in outlines only', () {
    const featureFile = '''
# language: fr
Fonctionnalité: Testing feature
  Plan du Scénario: Testing scenario
    Soit the app is running
    Alors I see <count> text

    Exemples:
      | count |
      | 1     |
  After:
    Alors I clean up
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_clean_up.dart';
import './step/the_app_is_running.dart';
import './step/i_see_text.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddTearDown(WidgetTester tester) async {
      await iCleanUp(tester);
    }
    testWidgets(\'\'\'Testing scenario (1)\'\'\', (tester) async {
      try {
        await theAppIsRunning(tester);
        await iSeeText(tester, 1);
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
