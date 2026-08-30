import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/util/dart_formatter.dart';
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

  test('header lines are kept verbatim, only blank runs collapse', () {
    const featureFile = '''


import 'package:flutter/cupertino.dart';



import 'package:flutter/gestures.dart';


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
      contains(
        "import 'package:flutter/cupertino.dart';\n\n"
        "import 'package:flutter/gestures.dart';\n",
      ),
    );
  });

  test('consecutive identical closing braces survive', () {
    const header = '''
void helper() {
  if (x) {
    y();
  }
}

''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: header + minimalFeatureFile,
    );

    // The header lines are trimmed but nothing is dropped: both `}` lines are
    // still there, and the block is still valid Dart.
    expect(
      generatedHeader(feature.dartContent),
      'void helper() {\nif (x) {\ny();\n}\n}\n',
    );
    expect(
      () => formatDartCode(generatedHeader(feature.dartContent)),
      returnsNormally,
    );
  });

  test('consecutive identical closing callbacks survive', () {
    const header = '''
void configure() {
  setUpAll(() {
    register(() {
      mockA();
    });
  });
}

''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: header + minimalFeatureFile,
    );

    expect(
      generatedHeader(feature.dartContent),
      'void configure() {\nsetUpAll(() {\nregister(() {\nmockA();\n});\n});\n}\n',
    );
    expect(
      () => formatDartCode(generatedHeader(feature.dartContent)),
      returnsNormally,
    );
  });
}

/// The lines copied out of the feature file: everything the generator wrote
/// between its own preamble and the first import it added.
///
/// Checked on its own rather than as part of the whole file, because the
/// generator writes its imports *below* the copied lines — a header holding a
/// declaration is a directive-ordering problem of its own, unrelated to which
/// header lines this function keeps.
String generatedHeader(String dartContent) {
  final lines = dartContent.split('\n');
  final firstImport = lines.indexWhere((line) => line.startsWith('import '));
  return lines
      .skip(3)
      .take(firstImport < 0 ? lines.length - 3 : firstImport - 3)
      .join('\n');
}
