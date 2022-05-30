import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stepFolderName parameter test ', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './../../../custom_steps/the_app_is_running.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
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
      generatorOptions:
          const GeneratorOptions(stepFolderName: '../../../custom_steps'),
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
