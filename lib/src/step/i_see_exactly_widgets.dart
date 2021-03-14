import 'package:bdd_widget_test/src/step/bdd_step.dart';

class ISeeExactlyWidgets implements BddStep {
  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I see exactly {4} {SomeWidget} widgets
Future<void> iSeeExactlyWidgets(
  WidgetTester tester,
  int count,
  Type type,
) async {
  expect(find.byType(type, skipOffstage: false), findsNWidgets(count));
}
''';
}
