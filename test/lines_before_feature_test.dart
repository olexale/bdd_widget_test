import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

import 'util/testing_data.dart';

void main() {
  test('lines before feature are copied to dart test', () {
    const expectedHeader = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

''';
    const expectedImports = '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

''';
    const additionalLines = '''
// Some comment with additional import
import 'package:flutter/cupertino.dart';

''';
    const expectedFeatureDart =
        '''
$expectedHeader$additionalLines${expectedImports}import './step/the_app_is_running.dart';

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
      input: additionalLines + minimalFeatureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('lines before feature survive a leading blank line', () {
    const featureFile = '''

import 'package:flutter/cupertino.dart';

Feature: Testing feature
    Scenario: Testing scenario
        Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(
      feature.dartContent,
      contains("import 'package:flutter/cupertino.dart';"),
    );
  });
}
