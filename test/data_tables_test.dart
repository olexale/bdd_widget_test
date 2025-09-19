import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

void main() {
  test('Data Tables ', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the following users exist <name> <twitter>
    | name            | twitter       |
    | 'Oleksandr'     | '@olexale'    |
    | 'Flutter'       | '@FlutterDev' |
    And I wait
    And user <name> with twitter <email> is still there
    | name | email |
    | 'Oleksandr' | '@olexale' |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_following_users_exist.dart';
import './step/i_wait.dart';
import './step/user_with_twitter_is_still_there.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theFollowingUsersExist(tester, 'Oleksandr', '@olexale');
      await theFollowingUsersExist(tester, 'Flutter', '@FlutterDev');
      await iWait(tester);
      await userWithTwitterIsStillThere(tester, 'Oleksandr', '@olexale');
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

  test('Data table with any cucumber keyword', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
    And the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
    But the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
    When the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
    And I wait
    Then the following songs
    | 'The Beatles'    | 'Let It Be'          |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_following_songs.dart';
import './step/i_wait.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
      await iWait(tester);
      await theFollowingSongs(tester, const bdd.DataTable([['The Beatles', 'Let It Be']]));
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

  test('Cucumber data table before example table', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
    And I wait
    And the following users exist <name> <twitter>
    | name            | twitter       |
    | 'Oleksandr'     | '@olexale'    |
    | 'Flutter'       | '@FlutterDev' |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_following_songs.dart';
import './step/i_wait.dart';
import './step/the_following_users_exist.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
      await iWait(tester);
      await theFollowingUsersExist(tester, 'Oleksandr', '@olexale');
      await theFollowingUsersExist(tester, 'Flutter', '@FlutterDev');
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

  test('Cucumber data table after example table', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the following users exist <name> <twitter>
    | name            | twitter       |
    | 'Oleksandr'     | '@olexale'    |
    | 'Flutter'       | '@FlutterDev' |
    And I wait
    And the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_following_users_exist.dart';
import './step/i_wait.dart';
import './step/the_following_songs.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theFollowingUsersExist(tester, 'Oleksandr', '@olexale');
      await theFollowingUsersExist(tester, 'Flutter', '@FlutterDev');
      await iWait(tester);
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
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

  test('Mixed data tables with a single example outline', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Testing scenario
    Given the following users exist <name> <twitter>
    | name            | twitter       |
    | 'Oleksandr'     | '@olexale'    |
    | 'Flutter'       | '@FlutterDev' |
    And band <band> is on tour
    And I wait
    And the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
    Examples:
    | band    |
    | 'Camel' |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_following_users_exist.dart';
import './step/band_is_on_tour.dart';
import './step/i_wait.dart';
import './step/the_following_songs.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Outline: Testing scenario ('Camel')\'\'\', (tester) async {
      await theFollowingUsersExist(tester, 'Oleksandr', '@olexale');
      await theFollowingUsersExist(tester, 'Flutter', '@FlutterDev');
      await bandIsOnTour(tester, 'Camel');
      await iWait(tester);
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
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

  test('Mixed data tables with multiple examples outline', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Testing scenario
    Given the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
    And band <band> is on tour
    And I wait
    Given the following users exist <name> <twitter>
    | name            | twitter       |
    | 'Oleksandr'     | '@olexale'    |
    | 'Flutter'       | '@FlutterDev' |

    Examples:
    | band        |
    | 'Camel'     |
    | 'Pearl Jam' |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_following_songs.dart';
import './step/band_is_on_tour.dart';
import './step/i_wait.dart';
import './step/the_following_users_exist.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Outline: Testing scenario ('Camel')\'\'\', (tester) async {
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
      await bandIsOnTour(tester, 'Camel');
      await iWait(tester);
      await theFollowingUsersExist(tester, 'Oleksandr', '@olexale');
      await theFollowingUsersExist(tester, 'Flutter', '@FlutterDev');
    });
    testWidgets(\'\'\'Outline: Testing scenario ('Pearl Jam')\'\'\', (tester) async {
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
      await bandIsOnTour(tester, 'Pearl Jam');
      await iWait(tester);
      await theFollowingUsersExist(tester, 'Oleksandr', '@olexale');
      await theFollowingUsersExist(tester, 'Flutter', '@FlutterDev');
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

  test('Cucumber data table in background', () {
    const featureFile = '''
Feature: Testing feature
  
  Background:
    Given I wait
    And the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
    And I wait

  Scenario: Testing scenario
    Given I wait
    And the following users exist <name> <twitter>
    | name            | twitter       |
    | 'Oleksandr'     | '@olexale'    |
    | 'Flutter'       | '@FlutterDev' |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_wait.dart';
import './step/the_following_songs.dart';
import './step/the_following_users_exist.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await iWait(tester);
      await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
      await iWait(tester);
    }
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await bddSetUp(tester);
      await iWait(tester);
      await theFollowingUsersExist(tester, 'Oleksandr', '@olexale');
      await theFollowingUsersExist(tester, 'Flutter', '@FlutterDev');
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

  test('Cucumber data table in after', () {
    const featureFile = '''
Feature: Testing feature
  
  After:
    Given I wait
    And the following users exist <name> <twitter>
    | name            | twitter       |
    | 'Oleksandr'     | '@olexale'    |
    | 'Flutter'       | '@FlutterDev' |
    And I wait

  Scenario: Testing scenario
    Given the following songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
   
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/i_wait.dart';
import './step/the_following_users_exist.dart';
import './step/the_following_songs.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    Future<void> bddTearDown(WidgetTester tester) async {
      await iWait(tester);
      await theFollowingUsersExist(tester, 'Oleksandr', '@olexale');
      await theFollowingUsersExist(tester, 'Flutter', '@FlutterDev');
      await iWait(tester);
    }
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      try {
        await theFollowingSongs(tester, const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
      } finally {
        await bddTearDown(tester);
      }
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
  test('Data table with parameters', () {
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the following {'Good'} songs
    | artist           | title                |
    | 'The Beatles'    | 'Let It Be'          |
    | 'Camel'          | 'Slow yourself down' |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_following_songs.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Testing scenario\'\'\', (tester) async {
      await theFollowingSongs(tester, 'Good', const bdd.DataTable([[artist, title], ['The Beatles', 'Let It Be'], ['Camel', 'Slow yourself down']]));
    });
  });
}
''';
    const expectedStep = '''
import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter_test/flutter_test.dart';

/// Usage: the following {'Good'} songs
Future<void> theFollowingSongs(WidgetTester tester, String param1, bdd.DataTable dataTable) async {
  throw UnimplementedError();
}
''';

    final feature = FeatureFile(
      featureDir: 'test.feature',
      package: 'test',
      input: featureFile,
    );
    expect(feature.dartContent, expectedFeatureDart);
    expect(
      (feature.getStepFiles().first as NewStepFile).dartContent,
      expectedStep,
    );
  });

  test('Scenario Outline with data table variables', () {
    const featureFile = '''
Feature: Testing feature
  Scenario Outline: Add and remove buttons work together
    Given the app is running
    When I tap add icon <times> times
    Then I see result
        | 'counter' | 'color' |
        | <counter> | <color> |
    Examples:
    | times | counter | color   |
    | 20    | '20'    | 'blue'  |
    | 25    | '25'    | 'green' |
''';

    const expectedFeatureDart = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';
import './step/i_tap_add_icon_times.dart';
import './step/i_see_result.dart';

void main() {
  group(\'\'\'Testing feature\'\'\', () {
    testWidgets(\'\'\'Outline: Add and remove buttons work together (20, '20', 'blue')\'\'\', (tester) async {
      await theAppIsRunning(tester);
      await iTapAddIconTimes(tester, 20);
      await iSeeResult(tester, const bdd.DataTable([['counter', 'color'], ['20', 'blue']]));
    });
    testWidgets(\'\'\'Outline: Add and remove buttons work together (25, '25', 'green')\'\'\', (tester) async {
      await theAppIsRunning(tester);
      await iTapAddIconTimes(tester, 25);
      await iSeeResult(tester, const bdd.DataTable([['counter', 'color'], ['25', 'green']]));
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
