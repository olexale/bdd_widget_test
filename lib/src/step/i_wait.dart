import 'package:bdd_widget_test/src/step/bdd_step.dart';

class IWait implements BddStep {
  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

Future<void> iWait(WidgetTester tester) async {
  await tester.pumpAndSettle();
}
''';
}
