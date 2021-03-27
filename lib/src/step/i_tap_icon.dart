import 'package:bdd_widget_test/src/step/bdd_step.dart';

class ITapIcon implements BddStep {
  @override
  String get content => '''
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: When I tap {Icons.add} icon
Future<void> iTapIcon(
  WidgetTester tester,
  IconData icon,
) async {
  await tester.tap(find.byIcon(icon));
  await tester.pump();
}
''';
}
