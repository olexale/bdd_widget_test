import 'package:flutter_test/flutter_test.dart';

/// Example: And I wait
Future<void> iWait(WidgetTester tester) async {
  await tester.pumpAndSettle();
}
