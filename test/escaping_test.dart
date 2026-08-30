import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/util/dart_formatter.dart';
import 'package:test/test.dart';

/// Titles and tags are interpolated into Dart string literals, so a fixture can
/// match its expected string character for character and still describe a file
/// that does not compile. `formatDartCode` parses before it pretty-prints, so
/// calling it asserts valid Dart - the same gate the build applies on the write
/// path (`lib/bdd_widget_test.dart`).
void expectValidDart(String generated) {
  expect(() => formatDartCode(generated), returnsNormally);
}

FeatureFile featureFrom(String input, {GeneratorOptions? options}) =>
    FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: input,
      generatorOptions: options ?? const GeneratorOptions(),
    );

void main() {
  test(r'$ in a feature title is escaped', () {
    const featureFile = r'''
Feature: Price is $100
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group('''Price is \$100''', () {
    testWidgets('''Testing scenario''', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
""";

    final feature = featureFrom(featureFile);
    expect(feature.dartContent, expectedFeatureDart);
    expectValidDart(feature.dartContent);
  });

  test(r'$ in a rule title is escaped', () {
    const featureFile = r'''
Feature: Testing feature
  Rule: Cost is $5
    Scenario: Testing scenario
      Given the app is running
''';

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group('''Testing feature''', () {
    group('''Cost is \$5''', () {
      testWidgets('''Testing scenario''', (tester) async {
        await theAppIsRunning(tester);
      });
    });
  });
}
""";

    final feature = featureFrom(featureFile);
    expect(feature.dartContent, expectedFeatureDart);
    expectValidDart(feature.dartContent);
  });

  test("''' in a scenario title does not close the literal", () {
    const featureFile = """
Feature: Testing feature
  Scenario: A ''' quoted title
    Given the app is running
""";

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group('''Testing feature''', () {
    testWidgets('''A \'\'\' quoted title''', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
""";

    final feature = featureFrom(featureFile);
    expect(feature.dartContent, expectedFeatureDart);
    expectValidDart(feature.dartContent);
  });

  // The only input that reaches the trailing-quote branch of the escape: a
  // lone apostrophe at the very end, which would otherwise run into the
  // closing delimiter and leave a fourth quote opening a new literal.
  test('a title ending in an apostrophe is escaped', () {
    const featureFile = """
Feature: Testing feature
  Scenario: Made in the '90s'
    Given the app is running
""";

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group('''Testing feature''', () {
    testWidgets('''Made in the \'90s\'''', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
""";

    final feature = featureFrom(featureFile);
    expect(feature.dartContent, expectedFeatureDart);
    expectValidDart(feature.dartContent);
  });

  test(r'$ in an Examples value is escaped in the generated title', () {
    const featureFile = r'''
Feature: Testing feature
  Scenario Outline: price
    Given the app is running

    Examples:
      | price |
      | $100  |
''';

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group('''Testing feature''', () {
    testWidgets('''price (\$100)''', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
""";

    final feature = featureFrom(featureFile);
    expect(feature.dartContent, expectedFeatureDart);
    expectValidDart(feature.dartContent);
  });

  test('hook calls get the escaped title', () {
    const featureFile = r'''
Feature: Price is $100
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './hook/hooks.dart';
import './step/the_app_is_running.dart';

void main() {
  setUpAll(() async {
    await Hooks.beforeAll();
  });
  tearDownAll(() async {
    await Hooks.afterAll();
  });

  group('''Price is \$100''', () {
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }
    Future<void> afterEach(String title, bool success, [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }
    testWidgets('''Testing scenario''', (tester) async {
      var success = true;
      try {
      await beforeEach('''Testing scenario''' );
      await theAppIsRunning(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          '''Testing scenario''',
          success,
        );
      }
    });
  });
}
""";

    final feature = featureFrom(
      featureFile,
      options: const GeneratorOptions(addHooks: true),
    );
    expect(feature.dartContent, expectedFeatureDart);
    expectValidDart(feature.dartContent);
  });

  test(r'$ and apostrophes in tags are escaped', () {
    const featureFile = r"""
@price$100 @it's
Feature: Testing feature
  @a$b
  Scenario: Testing scenario
    Given the app is running
""";

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['price\$100', 'it\'s'])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group('''Testing feature''', () {
    testWidgets('''Testing scenario''', (tester) async {
      await theAppIsRunning(tester);
    }, tags: ['a\$b']);
  });
}
""";

    final feature = featureFrom(featureFile);
    expect(feature.dartContent, expectedFeatureDart);
    expectValidDart(feature.dartContent);
  });
}
