import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util/testing_data.dart';

void main() {
  test('integration-related lines are added', () {
    const expectedFeatureDart = '''
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

  group(\'\'\'Testing feature\'\'\', () {
    Future<void> beforeEach(String title, [List<String>? tags]) async {
      await Hooks.beforeEach(title, tags);
    }
    Future<void> afterEach(String title, bool success, [List<String>? tags]) async {
      await Hooks.afterEach(title, success, tags);
    }
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      var success = true;
      try {
      await beforeEach(\'\'\'Testing scenario\'\'\' );
      await theAppIsRunning(tester);
      } catch (_) {
        success = false;
        rethrow;
      } finally {
        await afterEach(
          \'\'\'Testing scenario\'\'\',
          success,
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
      generatorOptions: const GeneratorOptions(addHooks: true),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
