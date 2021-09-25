import 'package:flutter_test/flutter_test.dart';

Future<void> iDoNotSeeText(
  WidgetTester tester,
  String text,
) async {
  expect(find.text(text), findsNothing);
}
