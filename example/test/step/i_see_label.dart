import 'package:flutter_test/flutter_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

Future<void> iSeeLabel(PatrolTester $, String text) async {
  expect($(text), findsOneWidget);
}
