import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: Then I don't see {Icons.add} icon
Future<void> iDontSeeIcon(
  WidgetTester tester,
  IconData icon,
) async {
  expect(find.byIcon(icon), findsNothing);
}
