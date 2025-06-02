// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@Tags(['slow', 'ui'])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './../../../step/common/the_app_is_running.dart';
import 'package:bdd_widget_test/step/i_see_text.dart';

void main() {
  group('''Counter''', () {
    testWidgets('''Initial counter value is 0''', (tester) async {
      await theAppIsRunning(tester);
      await iSeeText(tester, '0');
    }, tags: ['important', 'simple']);
  });
}
