// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import, directives_ordering

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import './../test/step/common/the_app_is_running.dart';
import 'package:bdd_widget_test/step/i_see_text.dart';
import 'package:bdd_widget_test/step/i_tap_icon.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> bddSetUp(WidgetTester tester) async {
    await theAppIsRunning(tester);
  }
  group('''Counter''', () {
    testWidgets('''Initial counter value is 0''', (tester) async {
      try {
        await bddSetUp(tester);
        await iSeeText(tester, '0');
      } on Exception catch (error, stackTrace) {
        debugPrint('${error.toString()}: $stackTrace');
        rethrow;
      }
    });
    testWidgets('''Add button increments the counter''', (tester) async {
      try {
        await bddSetUp(tester);
        await iTapIcon(tester, Icons.add);
        await iSeeText(tester, '1');
      } on Exception catch (error, stackTrace) {
        debugPrint('${error.toString()}: $stackTrace');
        rethrow;
      }
    });
  });
}
