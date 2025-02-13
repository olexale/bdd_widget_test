import 'package:bdd_widget_test/step/i_tap_icon.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> iTapIconTimes(
  WidgetTester tester,
  IconData icon,
  int times,
) async {
  for (var i = 0; i < times; i++) {
    await iTapIcon(tester, icon);
  }
}
