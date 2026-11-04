import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/util/dart_formatter.dart';
import 'package:test/test.dart';

void main() {
  test('Strings and whole-word numbers become parameters', () {
    const featureFile = r'''
Feature: Testing feature
  Scenario Outline: literals
    Then I see "Hello" text
    And I see "a" and "b" text
    And I see "" text
    And I see "42" text
    And I see "Don't panic" text
    And I see "say \"hi\"" text
    And I see "C:\\" text
    And I see "C:\temp" text
    And I see "cost $0" text
    And I see "use {braces}" text
    And I see "a{b" text
    And I see "a}b" text
    And I see "}{" text
    And I don't see "Hello" text
    And I tap "OK" text
    And I enter "x" into 1 input field
    And I see 'Hello' text
    And I see 42
    And I see 1.5
    And I see -3
    And I see (-3)
    And I see 1, 2 and 3
    And I see 10: 3 left
    And I see a/2 and 3/
    And I see the 42' mark
    And I see 2FA
    And I see v1
    And I see é3
    And I see ٣
    And I see 1.0.1
    And I see 19-20
    And I see 1,000
    And I see 1,5
    And I see 1:30
    And I see 1/2
    And I see 1'000
    And I see 3’000
    And I see 3+4
    And I see 1e3
    And I see .5
    And I see +7
    And I see 3.
    And I see --3
    And I see {get("a")} text
    And I see {const {'a': 1}} map
    And I see {const {"k": "v"}} and 2
    And I see {() {print('hey');}} code 3
    And I see {42} text
    And I see } and 3
    And I see {'a{b'} and 2
    And I see {'}'} and 2
    And I see <count> items
    And I see <item1> and <1>
    And I see "<greeting>" loudly
    And I see "Hello <name>" and 2
    And I see {Icons.add} icon <times> times and "x" label
    And I see {"a
    Examples:
      | count | item1 | 1 | greeting | name | times |
      | 5     | 6     | 7 | Hi       | Bob  | 2     |
''';

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_see_text.dart';
import './step/i_see_and_text.dart';
import './step/i_dont_see_text.dart';
import './step/i_tap_text.dart';
import './step/i_enter_into_input_field.dart';
import './step/i_see_hello_text.dart';
import './step/i_see.dart';
import './step/i_see_and.dart';
import './step/i_see_left.dart';
import './step/i_see_a_and.dart';
import './step/i_see_the_mark.dart';
import './step/i_see2fa.dart';
import './step/i_see_v1.dart';
import './step/i_see_e3.dart';
import './step/i_see101.dart';
import './step/i_see1920.dart';
import './step/i_see1000.dart';
import './step/i_see15.dart';
import './step/i_see130.dart';
import './step/i_see12.dart';
import './step/i_see3000.dart';
import './step/i_see34.dart';
import './step/i_see1e3.dart';
import './step/i_see5.dart';
import './step/i_see7.dart';
import './step/i_see3.dart';
import './step/i_see_map.dart';
import './step/i_see_code.dart';
import './step/i_see_items.dart';
import './step/i_see_loudly.dart';
import './step/i_see_icon_times_and_label.dart';

void main() {
  group('''Testing feature''', () {
    testWidgets('''literals (5, 6, 7, Hi, Bob, 2)''', (tester) async {
      await iSeeText(tester, 'Hello');
      await iSeeAndText(tester, 'a', 'b');
      await iSeeText(tester, '');
      await iSeeText(tester, '42');
      await iSeeText(tester, 'Don\'t panic');
      await iSeeText(tester, 'say "hi"');
      await iSeeText(tester, 'C:\\');
      await iSeeText(tester, 'C:\\temp');
      await iSeeText(tester, 'cost \$0');
      await iSeeText(tester, 'use {braces}');
      await iSeeText(tester, 'a{b');
      await iSeeText(tester, 'a}b');
      await iSeeText(tester, '}{');
      await iDontSeeText(tester, 'Hello');
      await iTapText(tester, 'OK');
      await iEnterIntoInputField(tester, 'x', 1);
      await iSeeHelloText(tester);
      await iSee(tester, 42);
      await iSee(tester, 1.5);
      await iSee(tester, -3);
      await iSee(tester, -3);
      await iSeeAnd(tester, 1, 2, 3);
      await iSeeLeft(tester, 10, 3);
      await iSeeAAnd(tester, 2, 3);
      await iSeeTheMark(tester, 42);
      await iSee2fa(tester);
      await iSeeV1(tester);
      await iSeeE3(tester);
      await iSee(tester);
      await iSee101(tester);
      await iSee1920(tester);
      await iSee1000(tester);
      await iSee15(tester);
      await iSee130(tester);
      await iSee12(tester);
      await iSee1000(tester);
      await iSee3000(tester);
      await iSee34(tester);
      await iSee1e3(tester);
      await iSee5(tester);
      await iSee7(tester);
      await iSee3(tester);
      await iSee3(tester);
      await iSeeText(tester, get("a"));
      await iSeeMap(tester, const {'a': 1});
      await iSeeAnd(tester, const {"k": "v"}, 2);
      await iSeeCode(tester, () {print('hey');}, 3);
      await iSeeText(tester, 42);
      await iSeeAnd(tester, 3);
      await iSeeAnd(tester, 'a{b', 2);
      await iSeeAnd(tester, '}', 2);
      await iSeeItems(tester, 5);
      await iSeeAnd(tester, 6, 7);
      await iSeeLoudly(tester, 'Hi');
      await iSeeAnd(tester, 'Hello Bob', 2);
      await iSeeIconTimesAndLabel(tester, Icons.add, 2, 'x');
      await iSee(tester);
    });
  });
}
""";

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(literalParameters: true),
    );
    expect(feature.dartContent, expectedFeatureDart);
    expect(() => formatDartCode(feature.dartContent), returnsNormally);
  });

  test('An outline value inside a string arrives as written', () {
    // Unfixed, `Don't panic` generated `iSeeText(tester, 'Don't panic')`,
    // which failed the build with a Dart parse error, and `a{b` generated
    // `iSee(tester)`: the argument was dropped and the test still compiled.
    const featureFile = r'''
Feature: Testing feature
  Scenario Outline: text cells
    Then I see "<v>" text
    And I see {'<v>'} label
    And I see {"<v>"} title
    Examples:
      | v           |
      | Don't panic |
      | cost $5     |
      | C:\temp     |
      | say "hi"    |
      | a{b         |
      | a}b         |
      | {}          |
''';

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_see_text.dart';
import './step/i_see_label.dart';
import './step/i_see_title.dart';

void main() {
  group('''Testing feature''', () {
    testWidgets('''text cells (Don't panic)''', (tester) async {
      await iSeeText(tester, 'Don\'t panic');
      await iSeeLabel(tester, 'Don\'t panic');
      await iSeeTitle(tester, "Don't panic");
    });
    testWidgets('''text cells (cost \$5)''', (tester) async {
      await iSeeText(tester, 'cost \$5');
      await iSeeLabel(tester, 'cost \$5');
      await iSeeTitle(tester, "cost \$5");
    });
    testWidgets('''text cells (C:\\temp)''', (tester) async {
      await iSeeText(tester, 'C:\\temp');
      await iSeeLabel(tester, 'C:\\temp');
      await iSeeTitle(tester, "C:\\temp");
    });
    testWidgets('''text cells (say "hi")''', (tester) async {
      await iSeeText(tester, 'say "hi"');
      await iSeeLabel(tester, 'say "hi"');
      await iSeeTitle(tester, "say \"hi\"");
    });
    testWidgets('''text cells (a{b)''', (tester) async {
      await iSeeText(tester, 'a{b');
      await iSeeLabel(tester, 'a{b');
      await iSeeTitle(tester, "a{b");
    });
    testWidgets('''text cells (a}b)''', (tester) async {
      await iSeeText(tester, 'a}b');
      await iSeeLabel(tester, 'a}b');
      await iSeeTitle(tester, "a}b");
    });
    testWidgets('''text cells ({})''', (tester) async {
      await iSeeText(tester, '{}');
      await iSeeLabel(tester, '{}');
      await iSeeTitle(tester, "{}");
    });
  });
}
""";

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(literalParameters: true),
    );
    expect(feature.dartContent, expectedFeatureDart);
    expect(() => formatDartCode(feature.dartContent), returnsNormally);
  });

  test('An outline value outside a string stays Dart', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: code cells
    Then I see {<v>} value
    And I see {[<v>, 'x']} list
    Examples:
      | v   |
      | 'a' |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_see_value.dart';
import './step/i_see_list.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'code cells ('a')\'\'\', (tester) async {
      await iSeeValue(tester, 'a');
      await iSeeList(tester, ['a', 'x']);
    });
  });
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(literalParameters: true),
    );
    expect(feature.dartContent, expectedFeatureDart);
    expect(() => formatDartCode(feature.dartContent), returnsNormally);
  });

  test('A generic step infers String and num parameters', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    When I invoke test with "a{b" and 1.5
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_invoke_test_with_and.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await iInvokeTestWithAnd(tester, 'a{b', 1.5);
    });
  });
}
''';

    const expectedStep = '''
import 'package:flutter_test/flutter_test.dart';

/// Usage: I invoke test with {'a{b'} and {1.5}
Future<void> iInvokeTestWithAnd(WidgetTester tester, String param1, num param2) async {
  throw UnimplementedError();
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(literalParameters: true),
    );
    expect(feature.dartContent, expectedFeatureDart);
    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedStep,
    );
  });

  test('Outline placeholders inside quotes take one String parameter', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: greeting
    Then I greet "Hello <name>" twice
    Examples:
      | name |
      | Bob  |
''';

    const expectedStep = '''
import 'package:flutter_test/flutter_test.dart';

/// Usage: I greet {'Hello <name>'} twice
Future<void> iGreetTwice(WidgetTester tester, String param1) async {
  throw UnimplementedError();
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(literalParameters: true),
    );
    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedStep,
    );
  });

  test('An inline table fills quoted placeholders once per row', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given user "<name>" exists
      | name    |
      | alice   |
      | O'Brien |
''';

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/user_exists.dart';

void main() {
  group('''Testing feature''', () {
    testWidgets('''Testing scenario''', (tester) async {
      await userExists(tester, 'alice');
      await userExists(tester, 'O\'Brien');
    });
  });
}
""";

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(literalParameters: true),
    );
    expect(feature.dartContent, expectedFeatureDart);
    expect(() => formatDartCode(feature.dartContent), returnsNormally);
  });

  test('A data table stays the last argument', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the users "admins"
      | name  |
      | "x"   |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_users.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theUsers(tester, 'admins', const bdd.DataTable([[name], ["x"]]));
    });
  });
}
''';

    const expectedStep = '''
import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter_test/flutter_test.dart';

/// Usage: the users {'admins'}
Future<void> theUsers(WidgetTester tester, String param1, bdd.DataTable dataTable) async {
  throw UnimplementedError();
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
      generatorOptions: const GeneratorOptions(literalParameters: true),
    );
    expect(feature.dartContent, expectedFeatureDart);
    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedStep,
    );
  });

  test('A placeholder inside {} adds no parameter of its own', () {
    // Independent of the option: `{<name>}` is passed as one argument.
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: greeting
    Then I greet {<name>} loudly
    Examples:
      | name    |
      | 'Hello' |
''';

    const expectedStep = '''
import 'package:flutter_test/flutter_test.dart';

/// Usage: I greet {<name>} loudly
Future<void> iGreetLoudly(WidgetTester tester, dynamic param1) async {
  throw UnimplementedError();
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedStep,
    );
  });

  test('With the option off, an outline value in a {} string stays raw', () {
    // Values there are Dart, so a hand-escaped `\'` keeps working.
    const featureFile = r'''
Feature: Testing feature
  Scenario Outline: raw cells
    Then I see {'<v>'} label
    Examples:
      | v      |
      | Don\'t |
''';

    const expectedFeatureDart = r"""
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_see_label.dart';

void main() {
  group('''Testing feature''', () {
    testWidgets('''raw cells (Don\\'t)''', (tester) async {
      await iSeeLabel(tester, 'Don\'t');
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

  test('With the option off, literals stay in the name', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Then I see "Hello" text
    And the counter is 42
    And I say "hello
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_see_hello_text.dart';
import './step/the_counter_is42.dart';
import './step/i_say_hello.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await iSeeHelloText(tester);
      await theCounterIs42(tester);
      await iSayHello(tester);
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

  test('An unclosed quote is reported with its location', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Then I say "hello
''';

    expect(
      () => FeatureFile(
        featureDir: 'test.feature',
        package: 'test',
        input: featureFile,
        generatorOptions: const GeneratorOptions(literalParameters: true),
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('test.feature'),
            contains('(3:5)'),
            contains('I say "hello'),
            contains('has a " with no closing "'),
          ),
        ),
      ),
    );
  });

  test('A step that is only literals names nothing', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Then "a" 42
''';

    expect(
      () => FeatureFile(
        featureDir: 'test.feature',
        package: 'test',
        input: featureFile,
        generatorOptions: const GeneratorOptions(literalParameters: true),
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('(3:5)'),
            contains('produces no valid Dart identifier'),
            contains('its text is parameters and nothing else'),
          ),
        ),
      ),
    );
  });

  test('A bare number that names nothing keeps its own message', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Then 42
''';

    expect(
      () => FeatureFile(
        featureDir: 'test.feature',
        package: 'test',
        input: featureFile,
        generatorOptions: const GeneratorOptions(literalParameters: true),
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains("'42' is not a name Dart accepts"),
        ),
      ),
    );
  });

  group('Placeholders and strings', () {
    test('A placeholder named with an apostrophe is filled in quotes', () {
      const featureFile = '''
Feature: Testing feature
  Scenario Outline: Testing scenario
    Then I see "<user's name>" text
    Examples:
      | user's name |
      | Bob         |
''';

      expect(_calls(featureFile), ["await iSeeText(tester, 'Bob');"]);
    });

    test('An inline table keyed by an apostrophe repeats the step', () {
      const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given user "<user's name>" exists
      | user's name |
      | alice       |
      | bob         |
''';

      expect(_calls(featureFile), [
        "await userExists(tester, 'alice');",
        "await userExists(tester, 'bob');",
      ]);
    });

    test('A value is not read for placeholders of its own', () {
      const featureFile = '''
Feature: Testing feature
  Scenario Outline: Testing scenario
    Then I see {'<value>'} text
    Examples:
      | value   | other |
      | <other> | hello |
''';

      expect(_calls(featureFile), ["await iSeeText(tester, '<other>');"]);
    });

    test('A value in a raw string arrives as written', () {
      const featureFile = r'''
Feature: Testing feature
  Scenario Outline: Testing scenario
    Then I see {r'<v>'} text
    Examples:
      | v       |
      | C:\temp |
      | Don't   |
''';

      expect(_calls(featureFile), [
        r"await iSeeText(tester, r'C:\temp');",
        r"await iSeeText(tester, 'Don\'t');",
      ]);
    });

    test('A raw string that cannot hold its value keeps its own text', () {
      const featureFile = r'''
Feature: Testing feature
  Scenario Outline: Testing scenario
    Then I see {r'$<v> in C:\'} text
    Examples:
      | v     |
      | Don't |
''';

      expect(_calls(featureFile), [
        r"await iSeeText(tester, '\$Don\'t in C:\\');",
      ]);
    });

    test('A value in a triple-quoted string is escaped for it', () {
      const featureFile = """
Feature: Testing feature
  Scenario Outline: Testing scenario
    Then I see {'''<v>'''} text
    Examples:
      | v     |
      | it's' |
""";

      expect(_calls(featureFile), [
        r"await iSeeText(tester, '''it\'s\'''');",
      ]);
    });

    test('A value in an interpolation is Dart, not text', () {
      const featureFile = r'''
Feature: Testing feature
  Scenario Outline: Testing scenario
    Then I see {'n: ${<v>.length}'} text
    Examples:
      | v     |
      | 'abc' |
''';

      expect(_calls(featureFile), [
        r"await iSeeText(tester, 'n: ${'abc'.length}');",
      ]);
    });
  });
}

/// The generated step calls, one per line, after checking they compile.
List<String> _calls(String input) {
  final content = FeatureFile(
    featureDir: 'test.feature',
    package: 'test',
    input: input,
    generatorOptions: const GeneratorOptions(literalParameters: true),
  ).dartContent;
  expect(() => formatDartCode(content), returnsNormally);
  return [
    for (final line in content.split('\n'))
      if (line.trim().startsWith('await ')) line.trim(),
  ];
}
