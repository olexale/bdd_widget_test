import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'i_tap_icon.dart';

Future<void> iTapIconTimes(
  WidgetTester tester,
  IconData icon,
  int times,
) async {
  for (var i = 0; i < times; i++) {
    await iTapIcon(tester, icon);
  }
}
