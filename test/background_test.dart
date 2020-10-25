import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Background steps appear before groups ', () {
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_server_always_return_errors.dart';
import './step/the_app_is_running.dart';

void main() {
  setUp(() async {
    await theServerAlwaysReturnErrors();
  });
  group('Testing feature', () {
    testWidgets('Testing scenario', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
''';

    final feature = FeatureFile(path: 'test.feature', input: featureFile);
    expect(feature.dartContent, expectedFeatureDart);
  });
}
