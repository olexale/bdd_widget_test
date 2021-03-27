import 'package:bdd_widget_test/src/step/bdd_step.dart';

class ISeeMultipleWidgets implements BddStep {
  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I see multiple {SomeWidget} widgets
Future<void> iSeeMultipleWidgets(
  WidgetTester tester,
  Type type,
) async {
  expect(find.byType(type), findsWidgets);
}
''';
}
