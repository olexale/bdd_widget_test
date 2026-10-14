import 'package:dummy_yaml/main.dart';
import 'package:patrol_finders/patrol_finders.dart';

Future<void> thePatrolAppIsRunning(PatrolTester $) async {
  await $.pumpWidgetAndSettle(const MyApp());
}
