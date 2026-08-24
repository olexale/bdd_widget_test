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
        featureDir: 'test.feature',
        package: 'test',
        input: featureFile,
      ).dartContent,
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('test.feature'),
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
        featureDir: 'test.feature',
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
        featureDir: 'test.feature',
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
        featureDir: 'test.feature',
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
}
