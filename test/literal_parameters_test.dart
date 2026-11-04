import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/literal_parameters.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

import 'escaping_test.dart' show expectValidDart, featureFrom;

const _on = GeneratorOptions(literalParameters: true);

String _rewrite(String stepText) {
  final result = rewriteLiteralParameters(stepText);
  expect(result, isNotNull, reason: stepText);
  return result!;
}

/// The generated feature's `testWidgets` body for [steps], one scenario.
String _calls(String steps, {GeneratorOptions options = _on}) {
  final feature = featureFrom('''
Feature: Literals
  Scenario: Testing scenario
$steps''', options: options);
  expectValidDart(feature.dartContent);
  return RegExp(
    'await (.*);',
  ).allMatches(feature.dartContent).map((m) => m.group(1)).join('\n');
}

/// The generated stubs, keyed by import path.
Map<String, String> _stubs(String feature) => {
  for (final step in featureFrom(
    feature,
    options: _on,
  ).getStepFiles().whereType<NewStepFile>())
    step.import: step.dartContent,
};

void main() {
  group('rewriteLiteralParameters', () {
    group('strings', () {
      const cases = {
        'I see "Hello" text': "I see {'Hello'} text",
        'I see "Don\'t panic" text': r"I see {'Don\'t panic'} text",
        r'I see "say \"hi\"" text': '''I see {'say "hi"'} text''',
        r'I see "C:\\" text': r"I see {'C:\\'} text",
        r'I see "C:\temp" text': r"I see {'C:\\temp'} text",
        r'I see "cost $0" text': r"I see {'cost \$0'} text",
        'I see "use {braces}" text': "I see {'use {braces}'} text",
        'I see "a{b" text': "I see {'a{b'} text",
        'I see "a}b" text': "I see {'a}b'} text",
        'I see "}{" text': "I see {'}{'} text",
        'I see "a" and "b" text': "I see {'a'} and {'b'} text",
        'I see "" text': "I see {''} text",
        'I see "42" text': "I see {'42'} text",
        "I don't see \"Hello\" text": "I don't see {'Hello'} text",
        "I see 'Hello' text": "I see 'Hello' text",
      };
      cases.forEach((input, expected) {
        test(input, () => expect(_rewrite(input), expected));
      });
    });

    group('numbers', () {
      const cases = {
        'the counter is 42': 'the counter is {42}',
        'the price is 1.5': 'the price is {1.5}',
        'the balance is -3': 'the balance is {-3}',
        'count is (-3)': 'count is ({-3})',
        'I see 42 text': 'I see {42} text',
        'I see 1, 2 and 3': 'I see {1}, {2} and {3}',
        '2FA is on': '2FA is on',
        'v1 release': 'v1 release',
        'release 1.0.1': 'release 1.0.1',
        'version 1.5.0': 'version 1.5.0',
        'score 19-20': 'score 19-20',
        'total 1,000': 'total 1,000',
        'I wait 1:30': 'I wait 1:30',
        'the score is 19:20': 'the score is 19:20',
        'I split 1/2 way': 'I split 1/2 way',
        "total 1'000": "total 1'000",
        'total 3’000': 'total 3’000',
        'at 10: 3 left': 'at {10}: {3} left',
        'a/2 and 3/': 'a/{2} and {3}/',
        "the 42' mark": "the {42}' mark",
        'ratio 1,5': 'ratio 1,5',
        'is 1e3': 'is 1e3',
        'offset .5': 'offset .5',
        'I see +7': 'I see +7',
        'I see 3.': 'I see 3.',
        'I see 3+4': 'I see 3+4',
        'I see --3': 'I see --3',
        'I see é3': 'I see é3',
        'I see ٣': 'I see ٣',
      };
      cases.forEach((input, expected) {
        test(input, () => expect(_rewrite(input), expected));
      });
    });

    group('{} and placeholders are left alone', () {
      const cases = {
        'I see {get("a")} text': 'I see {get("a")} text',
        "I see {const {'a': 1}} map": "I see {const {'a': 1}} map",
        'I see {"k": "v"} and 2': 'I see {"k": "v"} and {2}',
        "I run {func foo(){} func bar() {print('hey');}} code 3":
            "I run {func foo(){} func bar() {print('hey');}} code {3}",
        'I see {42} text': 'I see {42} text',
        // A brace inside a string in {} does not end the block.
        "I see {'a{b'} and 2": "I see {'a{b'} and {2}",
        "I see {'}'} and 2": "I see {'}'} and {2}",
        'I see } and 3': 'I see } and {3}',
        'I count <count> items': 'I count <count> items',
        'I see <item1> and <1>': 'I see <item1> and <1>',
        'I greet "<greeting>" loudly': "I greet {'<greeting>'} loudly",
        'I greet "Hello <name>" and 2': "I greet {'Hello <name>'} and {2}",
        'I tap {Icons.add} icon <times> times and "x" label':
            "I tap {Icons.add} icon <times> times and {'x'} label",
      };
      cases.forEach((input, expected) {
        test(input, () => expect(_rewrite(input), expected));
      });
    });

    test('an unclosed quote returns null', () {
      expect(
        rewriteLiteralParameters('I say "a" and "hello'),
        isNull,
      );
      expect(rewriteLiteralParameters(r'I say "hello\"'), isNull);
      // A backslash as the last character escapes nothing.
      expect(rewriteLiteralParameters(r'I see "a\'), isNull);
    });

    test('a quote inside an unclosed {} is not a delimiter', () {
      expect(_rewrite('I see {"a'), 'I see {"a');
    });
  });

  group('generation', () {
    test('predefined steps take quoted strings', () {
      expect(
        _calls('''
    Then I see "Hello" text
    And I don't see "Bye" text
    When I tap "OK" text
    And I enter "x" into 1 input field
'''),
        "iSeeText(tester, 'Hello')\n"
        "iDontSeeText(tester, 'Bye')\n"
        "iTapText(tester, 'OK')\n"
        "iEnterIntoInputField(tester, 'x', 1)",
      );
      final steps = featureFrom('''
Feature: Literals
  Scenario: Testing scenario
    Then I see "Hello" text
''', options: _on).getStepFiles();
      expect(steps.single.import, './step/i_see_text.dart');
    });

    test(r'$, \ and quotes compile to themselves', () {
      expect(
        _calls(r'''
    Then I see "cost $0" text
    And I see "C:\temp" text
    And I see "say \"hi\"" text
    And I see "Don't" text
    And I see "C:\\" text
'''),
        r"iSeeText(tester, 'cost \$0')"
        '\n'
        r"iSeeText(tester, 'C:\\temp')"
        '\n'
        '''iSeeText(tester, 'say "hi"')'''
        '\n'
        r"iSeeText(tester, 'Don\'t')"
        '\n'
        r"iSeeText(tester, 'C:\\')",
      );
    });

    test('braces in a quoted string reach the step as written', () {
      // Unescaped, `"a{b"` dropped its argument and still compiled:
      // `iSee(tester)`.
      expect(
        _calls('''
    Then I see "a{b" text
    And I see "a}b" text
    When I invoke "a{b" and "c}d"
'''),
        "iSeeText(tester, 'a{b')\n"
        "iSeeText(tester, 'a}b')\n"
        "iInvokeAnd(tester, 'a{b', 'c}d')",
      );
      expect(
        _stubs('''
Feature: Literals
  Scenario: Testing scenario
    When I invoke "a{b" and "c}d"
''')['./step/i_invoke_and.dart'],
        contains(
          'iInvokeAnd(WidgetTester tester, String param1, String param2)',
        ),
      );
    });

    test('braces in a quoted outline cell reach the step as written', () {
      // Unfixed, the cell `a{b` generated `iSee(tester)`: the argument was
      // dropped and the test still compiled.
      const feature = '''
Feature: Literals
  Scenario Outline: braces
    Then I see "<v>" text
    And I see {'<v>'} label
    Examples:
      | v   |
      | a{b |
      | a}b |
      | {}  |
''';
      final generated = featureFrom(feature, options: _on).dartContent;
      expectValidDart(generated);
      for (final value in ['a{b', 'a}b', '{}']) {
        expect(generated, contains("await iSeeText(tester, '$value');"));
        expect(generated, contains("await iSeeLabel(tester, '$value');"));
      }
      expect(
        _stubs(feature)['./step/i_see_label.dart'],
        contains('iSeeLabel(WidgetTester tester, String param1)'),
      );
    });

    test('a value inside a string literal arrives as written', () {
      // Unfixed, `Don't panic` generated `iSeeText(tester, 'Don't panic')`,
      // which failed the build with a Dart parse error.
      const feature = r'''
Feature: Literals
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
''';
      final generated = featureFrom(feature, options: _on).dartContent;
      expectValidDart(generated);
      const expected = {
        "Don't panic": (r"'Don\'t panic'", '''"Don't panic"'''),
        r'cost $5': (r"'cost \$5'", r'"cost \$5"'),
        r'C:\temp': (r"'C:\\temp'", r'"C:\\temp"'),
        'say "hi"': ('\'say "hi"\'', r'"say \"hi\""'),
      };
      expected.forEach((cell, literals) {
        final (single, double) = literals;
        expect(generated, contains('await iSeeText(tester, $single);'));
        expect(generated, contains('await iSeeLabel(tester, $single);'));
        expect(generated, contains('await iSeeTitle(tester, $double);'));
      });
    });

    test('an inline table escapes a value inside a string literal', () {
      expect(
        _calls('''
    Given user "<name>" exists
      | name    |
      | O'Brien |
'''),
        r"userExists(tester, 'O\'Brien')",
      );
    });

    test('a value outside a string literal stays Dart', () {
      const feature = '''
Feature: Literals
  Scenario Outline: code cells
    Then I see {<v>} value
    And I see {[<v>, 'x']} list
    Examples:
      | v     |
      | 'a'   |
''';
      final generated = featureFrom(feature, options: _on).dartContent;
      expectValidDart(generated);
      expect(generated, contains("await iSeeValue(tester, 'a');"));
      expect(generated, contains("await iSeeList(tester, ['a', 'x']);"));
    });

    test('with the option off, a value inside a {} string stays raw', () {
      // Cells there are Dart, so a hand-escaped `\'` keeps working.
      const feature = r'''
Feature: Literals
  Scenario Outline: raw cells
    Then I see {'<v>'} label
    Examples:
      | v      |
      | Don\'t |
''';
      final generated = featureFrom(feature).dartContent;
      expectValidDart(generated);
      expect(generated, contains(r"await iSeeLabel(tester, 'Don\'t');"));
    });

    test('numbers joined by : / or an apostrophe stay in the name', () {
      expect(
        _calls('''
    Then I wait 1:30
    And the score is 19:20
    When I split 1/2 way
    Then I see total 1'000
    And I see total 3’000
'''),
        'iWait130(tester)\n'
        'theScoreIs1920(tester)\n'
        'iSplit12Way(tester)\n'
        'iSeeTotal1000(tester)\n'
        'iSeeTotal3000(tester)',
      );
    });

    test('a generic stub infers String and num', () {
      const feature = '''
Feature: Literals
  Scenario: Testing scenario
    When I invoke test with "a" and 1.5
''';
      expect(
        _stubs(feature)['./step/i_invoke_test_with_and.dart'],
        contains(
          'Future<void> iInvokeTestWithAnd(WidgetTester tester, '
          'String param1, num param2) async {',
        ),
      );
    });

    test('outline placeholders inside quotes are one String parameter', () {
      const feature = '''
Feature: Literals
  Scenario Outline: greeting
    Then I greet "<greeting>" loudly
    And I greet "Hello <name>" twice
    And I count <count> items
    Examples:
      | greeting | name | count |
      | Hello    | Bob  | 3     |
''';
      final generated = featureFrom(feature, options: _on).dartContent;
      expectValidDart(generated);
      expect(generated, contains("await iGreetLoudly(tester, 'Hello');"));
      expect(generated, contains("await iGreetTwice(tester, 'Hello Bob');"));
      expect(generated, contains('await iCountItems(tester, 3);'));

      final stubs = _stubs(feature);
      expect(
        stubs['./step/i_greet_loudly.dart'],
        contains('iGreetLoudly(WidgetTester tester, String param1)'),
      );
      expect(
        stubs['./step/i_greet_twice.dart'],
        contains('iGreetTwice(WidgetTester tester, String param1)'),
      );
      expect(
        stubs['./step/i_count_items.dart'],
        contains('iCountItems(WidgetTester tester, dynamic count)'),
      );
    });

    test('an inline table repeating a step fills quoted placeholders', () {
      const feature = '''
Feature: Literals
  Scenario: Testing scenario
    Given user "<name>" exists
      | name  |
      | alice |
      | bob   |
''';
      expect(
        _calls('''
    Given user "<name>" exists
      | name  |
      | alice |
      | bob   |
'''),
        "userExists(tester, 'alice')\nuserExists(tester, 'bob')",
      );
      expect(
        _stubs(feature)['./step/user_exists.dart'],
        contains('userExists(WidgetTester tester, String param1)'),
      );
    });

    test('a data table stays the last argument', () {
      const feature = '''
Feature: Literals
  Scenario: Testing scenario
    Given the users "admins"
      | name  |
      | "x"   |
''';
      expect(
        _calls('''
    Given the users "admins"
      | name  |
      | "x"   |
'''),
        """theUsers(tester, 'admins', const bdd.DataTable([[name], ["x"]]))""",
      );
      expect(
        _stubs(feature)['./step/the_users.dart'],
        contains(
          'theUsers(WidgetTester tester, String param1, '
          'bdd.DataTable dataTable)',
        ),
      );
    });

    test('a placeholder inside {} adds no parameter of its own', () {
      // Independent of the option: `{<name>}` is passed as one argument.
      const feature = '''
Feature: Literals
  Scenario Outline: greeting
    Then I greet {<name>} loudly
    Examples:
      | name    |
      | 'Hello' |
''';
      final step = featureFrom(
        feature,
      ).getStepFiles().whereType<NewStepFile>().single;
      expect(
        step.dartContent,
        contains('iGreetLoudly(WidgetTester tester, dynamic param1) async'),
      );
    });

    test('with the option off, a brace inside a {} string is text', () {
      expect(
        _calls('''
    Then I see {'a{b'} text
    And I see {"}"} and {'{'} text
''', options: const GeneratorOptions()),
        "iSeeText(tester, 'a{b')\n"
        '''iSeeAndText(tester, "}", '{')''',
      );
    });

    test('with the option off, literals stay in the name', () {
      expect(
        _calls('''
    Then I see "Hello" text
    And the counter is 42
''', options: const GeneratorOptions()),
        'iSeeHelloText(tester)\ntheCounterIs42(tester)',
      );
    });
  });

  group('errors', () {
    test('an unclosed quote fails with its location', () {
      expect(
        () => featureFrom('''
Feature: Literals
  Scenario: Testing scenario
    Then I say "hello
''', options: _on),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            'Failed to parse test.feature:\n'
                '  (3:5): step \'I say "hello\' has a " with no closing " — '
                "close the string, or write the quote inside a {'...'} "
                'parameter',
          ),
        ),
      );
    });

    test('an unclosed quote is prose with the option off', () {
      expect(
        _calls(
          '    Then I say "hello\n',
          options: const GeneratorOptions(),
        ),
        'iSayHello(tester)',
      );
    });

    test('a step that is only a literal names nothing', () {
      for (final step in ['"Hello"', '"a" 42']) {
        expect(
          () => featureFrom('''
Feature: Literals
  Scenario: Testing scenario
    Then $step
''', options: _on),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              'Failed to parse test.feature:\n'
                  "  (3:5): step '$step' produces no valid Dart identifier: "
                  'its text is parameters and nothing else, so the step has '
                  'no name. Put a word of ASCII around the parameter, as in '
                  '\'I see "Hello" text\'',
            ),
          ),
        );
      }
    });

    test('a step that names nothing without the option keeps its message', () {
      expect(
        () => featureFrom('''
Feature: Literals
  Scenario: Testing scenario
    Then 42
''', options: _on),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains("'42' is not a name Dart accepts"),
          ),
        ),
      );
    });
  });
}
