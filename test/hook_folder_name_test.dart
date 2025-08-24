import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:test/test.dart';

void main() {
  test('relative hookFolderName', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureImportsDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../custom_hooks/hooks.dart';
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(
        addHooks: true,
        hookFolderName: '../../../custom_hooks',
      ),
    );
    expect(feature.dartContent, startsWith(expectedFeatureImportsDart));
  });

  test('absolute hookFolderName', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
''';

    const expectedFeatureImportsDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../custom_hooks/hooks.dart';
''';

    final feature = FeatureFile(
      featureDir: 'test/subdir/feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(
        addHooks: true,
        hookFolderName: 'custom_hooks',
      ),
    );
    expect(feature.dartContent, startsWith(expectedFeatureImportsDart));
  });
}
