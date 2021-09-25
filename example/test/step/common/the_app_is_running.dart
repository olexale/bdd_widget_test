import 'package:flutter_test/flutter_test.dart';
import 'package:dummy_yaml/main.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  final widget = MyApp();
  await tester.pumpWidget(widget);
}
