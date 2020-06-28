import 'package:bdd_widget_test/src/step/bdd_step.dart';

class ITapIconAndWait implements BddStep {
  @override
  String get content => '''
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> iTapIconAndWait(WidgetTester tester, IconData icon) async {
  await tester.tap(find.byIcon(icon));
  await tester.pumpAndSettle();
}
''';
}
