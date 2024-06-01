// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:patrol/patrol.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_patrol_app_is_running.dart';
import './step/i_see_label.dart';

void main() {
  group('''Counter''', () {
    Future<void> bddSetUp(PatrolIntegrationTester $) async {
      await thePatrolAppIsRunning($);
    }
    patrolTest('''Initial counter value is 0''', ($) async {
      await bddSetUp($);
      await iSeeLabel($, '0');
    },
     semanticsEnabled: false,
     );
  });
}
