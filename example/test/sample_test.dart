// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/common/the_app_is_running.dart';
import './step/i_do_not_see_text.dart';
import './step/i_see_text.dart';
import './step/i_tap_icon.dart';
import './step/i_tap_icon_times.dart';
import './step/i_see_result.dart';

void main() {
  group('''Counter''', () {
    Future<void> bddSetUp(WidgetTester tester) async {
      await theAppIsRunning(tester);
    }

    Future<void> bddTearDown(WidgetTester tester) async {
      await iDoNotSeeText(tester, 'surprise');
    }

    testWidgets('''Initial counter value is 0''', (tester) async {
      try {
        await bddSetUp(tester);
        await iSeeText(tester, '0');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Add button increments the counter''', (tester) async {
      try {
        await bddSetUp(tester);
        await iTapIcon(tester, Icons.add);
        await iSeeText(tester, '1');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Outline: Plus button increases the counter (0, '0')''',
        (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iTapIconTimes(tester, Icons.add, 0);
        await iSeeText(tester, '0');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Outline: Plus button increases the counter (1, '1')''',
        (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iTapIconTimes(tester, Icons.add, 1);
        await iSeeText(tester, '1');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets('''Outline: Plus button increases the counter (42, '42')''',
        (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iTapIconTimes(tester, Icons.add, 42);
        await iSeeText(tester, '42');
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets(
        '''Outline: Add and remove buttons work together (5, '5', 'blue')''',
        (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iTapIconTimes(tester, Icons.add, 5);
        await iSeeResult(
            tester,
            const bdd.DataTable([
              ['counter', 'color'],
              ['5', 'blue']
            ]));
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets(
        '''Outline: Add and remove buttons work together (15, '15', 'green')''',
        (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iTapIconTimes(tester, Icons.add, 15);
        await iSeeResult(
            tester,
            const bdd.DataTable([
              ['counter', 'color'],
              ['15', 'green']
            ]));
      } finally {
        await bddTearDown(tester);
      }
    });
    testWidgets(
        '''Outline: Add and remove buttons work together (30, '30', 'yellow')''',
        (tester) async {
      try {
        await bddSetUp(tester);
        await theAppIsRunning(tester);
        await iTapIconTimes(tester, Icons.add, 30);
        await iSeeResult(
            tester,
            const bdd.DataTable([
              ['counter', 'color'],
              ['30', 'yellow']
            ]));
      } finally {
        await bddTearDown(tester);
      }
    });
  });
}
