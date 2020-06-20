import 'package:bdd_widget_test/src/step/bdd_step.dart';

class TheAppInRunningStep implements BddStep {
  const TheAppInRunningStep(this.package);
  final String package;

  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';
import 'package:$package/main.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
}
''';
}
