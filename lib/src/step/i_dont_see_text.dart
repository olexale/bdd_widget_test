import 'package:bdd_widget_test/src/step/bdd_step.dart';

class IDontSeeText implements BddStep {
  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

Future<void> IDontSeeText(WidgetTester tester, String text) async {
  expect(find.text(text), findsNothing);
}
''';
}
