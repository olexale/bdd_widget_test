import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing_data.dart';

void main() {
  const expectedHeader = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

''';

  test('Empty feature file', () {
    const expectedFeatureDart = '''$expectedHeader

void main() {
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: '',
    );
    expect(feature.dartContent, expectedFeatureDart);
  });

  test('simplest feature file parses', () {
    const expectedFeatureDart =
        '''${expectedHeader}import './step/the_app_is_running.dart';

void main() {
  group('Testing feature', () {
    testWidgets('Testing scenario', (tester) async {
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

  test('Step with parameters', () {
    const expectedFeatureDart =
        '''${expectedHeader}import './step/the_app_is_running.dart';
import './step/i_see_text.dart';
import './step/i_see_icon.dart';

void main() {
  group('Testing feature', () {
    testWidgets('Testing scenario', (tester) async {
      await theAppIsRunning(tester);
      await iSeeText(tester, 'nice param');
      await iSeeIcon(tester, Icons.add);
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

  test('Several features in one file', () {
    const expectedFeatureDart = '''$expectedHeader// some comment

import './step/the_app_is_running.dart';

void main() {
  group('First testing feature', () {
    testWidgets('First testing scenario', (tester) async {
      await theAppIsRunning(tester);
    });
  });
  group('Second testing feature', () {
    testWidgets('First testing scenario', (tester) async {
      await theAppIsRunning(tester);
    });
    testWidgets('Second testing scenario', (tester) async {
      await theAppIsRunning(tester);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: bigFeatureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
