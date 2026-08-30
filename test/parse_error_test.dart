import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

void main() {
  test('A line that belongs nowhere is reported, not dropped', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running

This line belongs nowhere
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('test/test.feature'),
            contains('(5:1)'),
            contains('This line belongs nowhere'),
          ),
        ),
      ),
    );
  });

  test('Error positions point at the indented column, not column 1', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
  Background:
    Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          // `Background:` sits two spaces in, so the column is 3.
          contains('(4:3)'),
        ),
      ),
    );
  });

  test('A mistyped keyword is reported, not dropped', () {
    const featureFile = '''
Feature: Testing feature
  Scenrio: Testing scenario
    Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            // Column 5: the step is indented four spaces.
            contains('(3:5)'),
            contains('Given the app is running'),
            contains('is not part of a scenario'),
          ),
        ),
      ),
    );
  });

  test('A duplicated step reports the orphan, not the earlier valid one', () {
    const featureFile = '''
Feature: One
  Scenario: Testing scenario
    Given the app is running

Feature: Two
  Scenrio: Testing scenario
    Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          // Line 7, the orphaned step — not the identical line 3, which sits
          // in a scenario that parsed fine.
          contains('(7:5)'),
        ),
      ),
    );
  });

  test('A mistyped keyword inside a rule is reported', () {
    const featureFile = '''
Feature: Testing feature
  Rule: Testing rule
    Scenrio: Testing scenario
      Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('(4:7)'),
            contains('Given the app is running'),
          ),
        ),
      ),
    );
  });

  test('A bulleted description is prose when the feature has steps', () {
    const featureFile = '''
Feature: Testing feature
  Covers:
  * adding
  * removing

  Scenario: Testing scenario
    Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test',
      inputPath: 'test/test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, contains('await theAppIsRunning(tester);'));
  });

  test('A bulleted description is prose when the rule has steps', () {
    const featureFile = '''
Feature: Testing feature
  Rule: Testing rule
    Covers:
    * adding
    * removing

    Scenario: Testing scenario
      Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test',
      inputPath: 'test/test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, contains('await theAppIsRunning(tester);'));
  });

  test('Prose opening with a step keyword is prose when steps follow it', () {
    const featureFile = '''
Feature: Testing feature
  But only when the counter is zero

  Scenario: Testing scenario
    Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test',
      inputPath: 'test/test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, contains('await theAppIsRunning(tester);'));
  });

  // Known limitation, written down so it is not mistaken for a regression: a
  // block with no steps at all cannot tell prose from a swallowed step, and a
  // scenario with no steps generates a test body that asserts nothing.
  test(
    'A feature whose only content is a step-like description is reported',
    () {
      const featureFile = '''
Feature: Testing feature
  Covers:
  * adding
  * removing
''';

      expect(
        () => FeatureFile(
          featureDir: 'test',
          inputPath: 'test/test.feature',
          package: 'test',
          input: featureFile,
        ).dartContent,
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('* adding'),
          ),
        ),
      );
    },
  );

  test('Prose opening with Given is prose when the feature has steps', () {
    const featureFile = '''
Feature: Testing feature
  Given the size of the counter, only the basics are covered here.

  Scenario: Testing scenario
    Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test',
      inputPath: 'test/test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, contains('await theAppIsRunning(tester);'));
  });

  // The feature itself holds no scenario — the steps that keep its description
  // prose live one level down, inside the rule.
  test('A description is prose when the only steps are inside a rule', () {
    const featureFile = '''
Feature: Testing feature
  Covers:
  * adding
  * removing

  Rule: Testing rule
    Scenario: Testing scenario
      Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test',
      inputPath: 'test/test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, contains('await theAppIsRunning(tester);'));
  });

  // An `After:` block is a scenario by the time the parser sees it, so its
  // steps count too: a feature that is nothing but a teardown keeps its prose.
  test('A description is prose when the only steps are in an After: block', () {
    const featureFile = '''
Feature: Testing feature
  Covers:
  * adding
  * removing

  After:
    Given I clean up
''';

    final feature = FeatureFile(
      featureDir: 'test',
      inputPath: 'test/test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, contains('await iCleanUp(tester);'));
  });

  // Everything above the first feature keyword is copied to Dart unchecked, so
  // a file that never reaches a feature keyword has nothing validated in it at
  // all — and generates a `main()` with no tests, or a syntax error whose line
  // numbers point at the generated file rather than at this one.
  test('A mistyped feature keyword is reported, not copied out as Dart', () {
    const featureFile = '''
Featur: Testing feature
  Scenario: Testing scenario
    Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('(1:1)'),
            contains("no 'Feature:' keyword"),
            contains('Featur: Testing feature'),
          ),
        ),
      ),
    );
  });

  test('A file with no feature keyword is reported, not left empty', () {
    const featureFile = '''
# a comment the parser allows here
@slow

Testing feature
  Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('(4:1)'), contains('Testing feature')),
        ),
      ),
    );
  });

  // `//` is Dart, so a feature commented out this way is text sitting over a
  // feature keyword that is gone: the greenest of empty test files.
  test('A commented-out feature is reported, not run empty', () {
    const featureFile = '''
// Feature: Testing feature
//   Scenario: Testing scenario
//     Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('(1:1)'),
            contains('// Feature: Testing feature'),
          ),
        ),
      ),
    );
  });

  // Comments and tags are what Gherkin allows above a feature, so a file
  // holding nothing else declares nothing and is left to generate nothing.
  test('A feature file of nothing but comments is left alone', () {
    const featureFile = '''
# not a feature yet
@slow
''';

    final feature = FeatureFile(
      featureDir: 'test',
      inputPath: 'test/test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, contains('void main() {\n}'));
  });

  // Gherkin honours `# language:` above the first feature keyword and nowhere
  // else: below it the line is a comment, and the file is read in English.
  test('A language comment below the feature keyword is read as a comment', () {
    const featureFile = '''
Feature: Testing feature
  # language: fr
  Scenario: Testing scenario
    Given the app is running
''';

    final feature = FeatureFile(
      featureDir: 'test',
      inputPath: 'test/test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, contains('await theAppIsRunning(tester);'));
  });

  test('A scenario in a dialect the parser ignored is reported', () {
    const featureFile = '''
Feature: Testing feature
  # language: fr
  Scénario: Testing scenario
    Etant donné que the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('(4:5)'), contains("step 'Etant donné que")),
        ),
      ),
    );
  });

  // The keywords localise, but a step name is built out of ASCII word
  // characters, and text in another script holds none. The file is valid
  // Gherkin all the way to this line, and used to generate `./step/.dart`
  // alongside an `await (tester);` — two files that do not compile, with an
  // error naming neither.
  test('A step whose text holds no ASCII word character is reported', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given アプリが起動している
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('test/test.feature'),
            contains('(3:5)'),
            contains("step 'アプリが起動している'"),
            contains('no valid Dart identifier'),
          ),
        ),
      ),
    );
  });

  test('A step of that shape inside a rule carries its own position', () {
    const featureFile = '''
Feature: Testing feature
  Rule: A rule
    Scenario: Testing scenario
      When データがある
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('(4:7)'), contains("step 'データがある'")),
        ),
      ),
    );
  });

  // A step is checked wherever it was written, and the walk over the feature
  // has a branch per place one can sit. A branch that goes missing does not
  // fail loudly — it just stops rejecting — so each is pinned here.
  test('A step of that shape in a Background: carries its own position', () {
    const featureFile = '''
Feature: Testing feature
  Background:
    Given アプリが起動している
  Scenario: Testing scenario
    Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('(3:5)'), contains("step 'アプリが起動している'")),
        ),
      ),
    );
  });

  // `After:` is this package's own keyword, rewritten into a scenario under a
  // reserved name before the parser sees it — so it is the scenario branch of
  // the walk that has to catch this one.
  test('A step of that shape in an After: carries its own position', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the app is running
  After:
    Given ログアウトする
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('(5:5)'), contains("step 'ログアウトする'")),
        ),
      ),
    );
  });

  test("A step of that shape in a rule's Background: is reported", () {
    const featureFile = '''
Feature: Testing feature
  Rule: A rule
    Background:
      Given データがある
    Scenario: Testing scenario
      Given the app is running
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('(4:7)'), contains("step 'データがある'")),
        ),
      ),
    );
  });

  // A name is more than a non-empty string: it may not open with a digit, and
  // it may not open with an underscore either — that one names a function the
  // generated test imports and then cannot see.
  test('A step whose text opens with an underscore is reported', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given _debug mode is on
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('(3:5)'), contains("step '_debug mode is on'")),
        ),
      ),
    );
  });

  test('A step whose text opens with a digit is reported', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given 2FA is on
''';

    expect(
      () => FeatureFile(
        featureDir: 'test',
        inputPath: 'test/test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('(3:5)'), contains("step '2FA is on'")),
        ),
      ),
    );
  });
}
