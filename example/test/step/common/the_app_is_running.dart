import 'package:dummy_yaml/main.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  const widget = MyApp();
  await tester.pumpWidget(widget);
}
