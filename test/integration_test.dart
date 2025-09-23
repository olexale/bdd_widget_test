import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

import 'util/testing_data.dart';

void main() {
  test('integration-related lines are added', () {
    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './step/the_app_is_running.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
      input: minimalFeatureFile,
      includeIntegrationTestBinding: true,
      includeIntegrationTestImport: true,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test(
    'integration-related lines are not added if includeIntegrationTestBinding is false',
    () {
      const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './step/the_app_is_running.dart';

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
        input: minimalFeatureFile,
        includeIntegrationTestImport: true,
      );
      expect(feature.dartContent, expectedFeatureDart);
    },
  );

  test('integration-related code is not added by default', () {
    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';

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
      input: minimalFeatureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
