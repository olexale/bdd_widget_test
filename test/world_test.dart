import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/testing_data.dart';

void main() {
  test('Steps get the world parameter if it is enabled', () {
    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:bdd_widget_test/world.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      final World world = World.empty();
      await theAppIsRunning(tester, world);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test/subdir/feature',
      package: 'test',
      input: minimalFeatureFile,
      generatorOptions: const GeneratorOptions(
        addWorld: true,
      ),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('Hooks get world parameter added to them if world is enabled', () {
    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:bdd_widget_test/world.dart';
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

  group(\'\'\'Testing feature\'\'\', () {
    Future<void> beforeEach(String title, World world, [List<String>? tags]) async {
      await Hooks.beforeEach(title, world, tags);
    }
    Future<void> afterEach(String title, bool success, World world, [List<String>? tags]) async {
      await Hooks.afterEach(title, success, world, tags);
    }
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      final World world = World.empty();
      bool success = true;
      try {
        await beforeEach(\'\'\'Testing scenario\'\'\', world);
        await theAppIsRunning(tester, world);
      } on TestFailure {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          \'\'\'Testing scenario\'\'\',
          success,
          world,
        );
      }
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test/subdir/feature',
      package: 'test',
      input: minimalFeatureFile,
      generatorOptions: const GeneratorOptions(
        addHooks: true,
        addWorld: true,
      ),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('After steps get the world parameter', () {
    const featureFile = '''
Feature: Testing feature
  After:
    And the test finishes
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:bdd_widget_test/world.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_test_finishes.dart';
import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddTearDown(WidgetTester tester, World world) async {
      await theTestFinishes(tester, world);
    }
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      final World world = World.empty();
      try {
        await theAppIsRunning(tester, world);
      } finally {
        await bddTearDown(tester, world);
      }
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test/subdir/feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(
        addWorld: true,
      ),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('Background steps get the world parameter', () {
    const featureFile = '''
Feature: Testing feature
  Background:
    Given the server always return errors
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:bdd_widget_test/world.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_server_always_return_errors.dart';
import './step/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddSetUp(WidgetTester tester, World world) async {
      await theServerAlwaysReturnErrors(tester, world);
    }
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      final World world = World.empty();
      await bddSetUp(tester, world);
      await theAppIsRunning(tester, world);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test/subdir/feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(
        addWorld: true,
      ),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
