import 'package:bdd_widget_test/src/step/bdd_step.dart';

class ISeeWidget implements BddStep {
  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I see {SomeWidget} widget
Future<void> iSeeWidget(
  WidgetTester tester,
  Type type,
) async {
  expect(find.byType(type), findsOneWidget);
}
''';
}
