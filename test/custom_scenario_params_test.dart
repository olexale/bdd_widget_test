import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Feature Custom Scenario Parameters using tag only', () {
    const featureFile = '''
Feature: Testing feature 
  @scenarioParams: skip: false, timeout: Timeout(Duration(seconds: 1))
  Scenario: Testing scenario
    Given the app is running with patrol

''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './step/the_app_is_running_with_patrol.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theAppIsRunningWithPatrol(tester);
    },
     skip: false,
     timeout: Timeout(Duration(seconds: 1)),
     );
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      isIntegrationTest: true,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
