import 'package:flutter_test/flutter_test.dart';

/// Example: Then I dismiss the page
Future<void> dismissThePage(
  WidgetTester tester,
) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}
