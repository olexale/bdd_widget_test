import 'package:bdd_widget_test/src/step/bdd_step.dart';

class IDismissThePage implements BddStep {
  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I dismiss the page
Future<void> iDismissThePage(
  WidgetTester tester,
) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}
''';
}
