import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

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
// ignore_for_file: unused_import, directives_ordering

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
}
