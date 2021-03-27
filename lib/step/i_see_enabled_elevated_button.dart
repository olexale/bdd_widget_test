import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I see enabled elevated button
Future<void> iSeeEnabledElevatedButton(
  WidgetTester tester,
) async {
  final button = find.byType(ElevatedButton);

  expect((tester.firstWidget(button) as ElevatedButton).enabled, true);
}
