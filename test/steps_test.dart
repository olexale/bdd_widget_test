import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/util/dart_formatter.dart';
import 'package:test/test.dart';

void main() {
  test('Empty feature file parses', () {
    const path = 'test';

    final feature = FeatureFile(
      featureDir: '$path.feature',
      package: path,
      input: '',
    );
    expect(feature.getStepFiles().length, 0);
  });

  test('A brace or quote inside a string in {} is text', () {
    const featureFile = r"""
Feature: Testing feature
  Scenario: Testing scenario
    Then I see {'a{b'} text
    And I see {"}"} and {'{'} text
    And I see {"it's }"} text
    And I see {'it\'s }'} text
    And I see {'a\\'} text
    And I see {'''it's'''} and {'''ok's'''} text
    And I see {r'C:\'} and {'don\'t'} text
    And I see {'a ${'}'} b'} and {1} text
""";

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_see_text.dart';
import './step/i_see_and_text.dart';

void main() {
  group('''Testing feature''', () {
    testWidgets('''Testing scenario''', (tester) async {
      await iSeeText(tester, 'a{b');
      await iSeeAndText(tester, "}", '{');
      await iSeeText(tester, "it's }");
      await iSeeText(tester, 'it\'s }');
      await iSeeText(tester, 'a\\');
      await iSeeAndText(tester, '''it's''', '''ok's''');
      await iSeeAndText(tester, r'C:\', 'don\'t');
      await iSeeAndText(tester, 'a ${'}'} b', 1);
    });
  });
}
""";

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
    expect(() => formatDartCode(feature.dartContent), returnsNormally);
  });
}
