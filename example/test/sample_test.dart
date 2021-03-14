// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/common/the_app_is_running.dart';
import './step/i_do_not_see_text.dart';
import 'package:bdd_sample/i_see_text.dart';

void main() {
  Future<void> bddSetUp(WidgetTester tester) async {
    await theAppIsRunning(tester);
  }
  Future<void> bddTearDown(WidgetTester tester) async {
    await iDoNotSeeText(tester, '42');
  }
  group('Counter', () {
    customTestMethodName('Initial counter value is 0', (tester) async {
      await bddSetUp(tester);
      await theAppIsRunning(tester);
      await iSeeText(tester, '0');
      await bddTearDown(tester);
    });
  });
}
