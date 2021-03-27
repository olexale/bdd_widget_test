import 'package:bdd_widget_test/src/step/bdd_step.dart';

class ISeeDisabledElevatedButton implements BddStep {
  @override
  String get content => '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I see disabled elevated button
Future<void> iSeeDisabledElevatedButton(
  WidgetTester tester,
) async {
  final button = find.byType(ElevatedButton);

  expect((tester.firstWidget(button) as ElevatedButton).enabled, false);
}
''';
}
