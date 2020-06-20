import 'package:bdd_widget_test/src/step/bdd_step.dart';

class ISeeIcon implements BddStep {
  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

Future<void> iSeeIcon(WidgetTester tester, IconData icon) async {
  expect(find.byIcon(icon), findsOneWidget);
}
''';
}
