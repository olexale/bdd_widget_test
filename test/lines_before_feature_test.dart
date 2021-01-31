import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing_data.dart';

void main() {
  test('lines before feature are copied to dart test', () {
    const expectedHeader = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

''';
    const additionalLines = '''
// Some comment with additional import
import 'package:flutter/cupertino.dart';

''';
    const expectedFeatureDart = expectedHeader +
        additionalLines +
        '''
import './step/the_app_is_running.dart';

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
      input: additionalLines + minimalFeatureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
  });
}
