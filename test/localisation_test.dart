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

  // The Dart headers are blanked out before the file is parsed, so a
  // declaration written under them still sits above the feature, which is where
  // Gherkin honours one.
  test('A language declaration below the Dart headers is honoured', () {
    const featureFile = '''
import 'dart:async';

# language: uk
Функціонал: Лічильник
  Сценарій: сценарій
    Тоді I see 1 text
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(
      feature.dartContent,
      allOf(
        contains("import 'dart:async';"),
        contains("group('''Лічильник'''"),
        contains('iSee1Text'),
      ),
    );
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

  // A declaration below the first feature keyword is an ordinary comment, and
  // must not be carried into a later feature's chunk — there it would sit above
  // that feature's keyword, which is the one place Gherkin does honour one.
  test('A language comment in one feature does not reach the next', () {
    const featureFile = '''
Feature: one
  # language: fr
  Scenario: s
    Given the app is running

Feature: two
  Scenario: t
    Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(
      feature.dartContent,
      allOf(contains("group('''one'''"), contains("group('''two'''")),
    );
  });

  test('A missing feature keyword is named in the declared language', () {
    const featureFile = '''
# language: fr
Scénario: un
  Soit the app is running
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
          contains("no 'Fonctionnalité:' keyword"),
        ),
      ),
    );
  });

  // Without a feature keyword the file never reaches the parser, so the
  // unsupported code has to be reported here or not at all.
  test('An unknown language is reported when no feature keyword parses', () {
    const featureFile = '''
# language: zz
Fonctionnalité: Testing feature
  Scénario: Testing scenario
    Soit the app is running
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
          allOf(contains('(1:1)'), contains('Language not supported: zz')),
        ),
      ),
    );
  });
}
