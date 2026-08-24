import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

void main() {
  test('Scenario Outline', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: eating
    Given there are <start> cucumbers
    When I eat <eat> cucumbers
    Then I should have <left> cucumbers

    Examples:
      | start | eat | left |
      |    12 |   5 |    7 |
      |    20 |   5 |   15 |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/there_are_cucumbers.dart';
import './step/i_eat_cucumbers.dart';
import './step/i_should_have_cucumbers.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'eating (12, 5, 7)\'\'\', (tester) async {
      await thereAreCucumbers(tester, 12);
      await iEatCucumbers(tester, 5);
      await iShouldHaveCucumbers(tester, 7);
    });
    testWidgets(\'\'\'eating (20, 5, 15)\'\'\', (tester) async {
      await thereAreCucumbers(tester, 20);
      await iEatCucumbers(tester, 5);
      await iShouldHaveCucumbers(tester, 15);
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

  test('Scenario Outline Parameters', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: params
    Given there are mixed <int> <String> <Custom> parameters

    Scenarios:
      | int   | String  | Custom     |
      |  12   |   '5'   |  Icons.add |
      |  '20' |   5.0   |   MyClass  |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/there_are_mixed_parameters.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'params (12, '5', Icons.add)\'\'\', (tester) async {
      await thereAreMixedParameters(tester, 12, '5', Icons.add);
    });
    testWidgets(\'\'\'params ('20', 5.0, MyClass)\'\'\', (tester) async {
      await thereAreMixedParameters(tester, '20', 5.0, MyClass);
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

  test('Scenario Outline Variables in Array', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Variables in array
    When I tap {[<plus>, <minus>]} times

    Examples:
      | plus | minus |
      | 1    | 2     |
      | 42   | -84   |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_tap_times.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Variables in array (1, 2)\'\'\', (tester) async {
      await iTapTimes(tester, [1, 2]);
    });
    testWidgets(\'\'\'Variables in array (42, -84)\'\'\', (tester) async {
      await iTapTimes(tester, [42, -84]);
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

  test('Scenario Outline Variables in Named Parameters', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Variables in named parameter variable
    When I tap {plus: <plus>, minus: <minus>} times

    Examples:
      | plus | minus |
      | 1    | 2     |
      | 42   | -84   |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_tap_times.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Variables in named parameter variable (1, 2)\'\'\', (tester) async {
      await iTapTimes(tester, plus: 1, minus: 2);
    });
    testWidgets(\'\'\'Variables in named parameter variable (42, -84)\'\'\', (tester) async {
      await iTapTimes(tester, plus: 42, minus: -84);
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

  test('Scenario Outline Variables Mixed Context', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Mixed variables
    When I perform <action> with {data: [<value1>, <value2>]} and <standalone> parameter

    Examples:
      | action | value1 | value2 | standalone |
      | 'tap'  | 1      | 2      | Icons.add  |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_perform_with_and_parameter.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Mixed variables ('tap', 1, 2, Icons.add)\'\'\', (tester) async {
      await iPerformWithAndParameter(tester, 'tap', data: [1, 2], Icons.add);
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

  test('Scenario Outline Variables with Non-Placeholder Angle Brackets', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Non-placeholder angle brackets
    When I check if <value> is less than <other>

    Examples:
      | value | other |
      | 5     | 10    |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_check_if_is_less_than.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Non-placeholder angle brackets (5, 10)\'\'\', (tester) async {
      await iCheckIfIsLessThan(tester, 5, 10);
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

  test('Scenario Outline Nested Braces with Variables', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Nested braces
    When I use {outer: {inner: <value>}} structure

    Examples:
      | value |
      | 42    |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_use_structure.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Nested braces (42)\'\'\', (tester) async {
      await iUseStructure(tester, outer: {inner: 42});
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

  test('Scenario Outline Multiple Variables in Same Braces', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Multiple vars same block
    When I process {a: <first>, b: <second>, c: <third>} data

    Examples:
      | first | second | third |
      | 1     | 2      | 3     |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_process_data.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Multiple vars same block (1, 2, 3)\'\'\', (tester) async {
      await iProcessData(tester, a: 1, b: 2, c: 3);
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

  test('Scenario Outline Variables Outside and Inside Braces', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Mix outside and inside
    When I call <method> with {args: [<arg1>, <arg2>]}

    Examples:
      | method | arg1 | arg2 |
      | 'run'  | 10   | 20   |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_call_with.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Mix outside and inside ('run', 10, 20)\'\'\', (tester) async {
      await iCallWith(tester, 'run', args: [10, 20]);
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

  test('Scenario Outline Sequential Variables', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Sequential variables
    When I add <first> and <second> and <third>

    Examples:
      | first | second | third |
      | 1     | 2      | 3     |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_add_and_and.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Sequential variables (1, 2, 3)\'\'\', (tester) async {
      await iAddAndAnd(tester, 1, 2, 3);
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

  test('Scenario Outline With Non-Placeholder Angle Bracket', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Angle bracket not a placeholder
    When I process {operator: <, value: <val>} data

    Examples:
      | val |
      | 50  |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_process_data.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Angle bracket not a placeholder (50)\'\'\', (tester) async {
      await iProcessData(tester, operator: <, value: 50);
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

  test('Scenario Outline with Empty Examples Table', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Empty outline
    When I test <value> parameter

    Examples:
      | value |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_test_parameter.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
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

  test('Scenario Outline with Unicode Characters in Variables', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Unicode variables
    When I see <emoji> icon

    Examples:
      | emoji |
      | '🚀'  |
      | '💯'  |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_see_icon.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Unicode variables ('🚀')\'\'\', (tester) async {
      await iSeeIcon(tester, '🚀');
    });
    testWidgets(\'\'\'Unicode variables ('💯')\'\'\', (tester) async {
      await iSeeIcon(tester, '💯');
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
}
