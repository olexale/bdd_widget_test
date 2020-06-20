import 'package:bdd_widget_test/src/step/bdd_step.dart';

class DismissThePage implements BddStep {
  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

Future<void> dismissThePage(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}
''';
}
