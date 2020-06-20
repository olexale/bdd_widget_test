import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing_data.dart';

void main() {
  const expectedHeader = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

''';

  test('Empty feature file', () {
    const expectedFeatureDart = expectedHeader +
        '''

void main() {
}
''';

    final feature = FeatureFile(path: 'test.feature', input: '');
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('simplest feature file parses', () {
    const expectedFeatureDart = expectedHeader +
        '''
import './step/the_app_is_running.dart';

void main() {
  group('Testing feature', () {
    testWidgets('Testing scenario', (WidgetTester tester) async {
      await TheAppIsRunning(tester);
    });
  });
}
''';

    final feature =
        FeatureFile(path: 'test.feature', input: minimalFeatureFile);
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('Step with parameters', () {
    const expectedFeatureDart = expectedHeader +
        '''
import './step/the_app_is_running.dart';
import './step/i_see_text.dart';
import './step/i_see_icon.dart';

void main() {
  group('Testing feature', () {
    testWidgets('Testing scenario', (WidgetTester tester) async {
      await TheAppIsRunning(tester);
      await ISeeText(tester, 0);
      await ISeeIcon(tester, Icons.add);
    });
  });
}
''';

    final feature = FeatureFile(path: 'test.feature', input: featureFile);
    expect(feature.dartContent, expectedFeatureDart);
  });
}
