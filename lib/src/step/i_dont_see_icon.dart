import 'package:bdd_widget_test/src/step/bdd_step.dart';

class IDontSeeIcon implements BddStep {
  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

Future<void> iDontSeeIcon(WidgetTester tester, IconData icon) async {
  expect(find.byIcon(icon), findsNothing);
}
''';
}
