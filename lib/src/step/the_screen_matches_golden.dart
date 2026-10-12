import 'package:bdd_widget_test/src/step/bdd_step.dart';

class TheScreenMatchesGolden implements BddStep {
  @override
  String get content => r'''
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Example: Then the screen matches golden {'home'}
///
/// The path is resolved relative to the generated `*_test.dart` file, so in a
/// feature file in `test/` this step compares with `test/goldens/home.png`.
Future<void> theScreenMatchesGolden(
  WidgetTester tester,
  String name,
) async {
  await expectLater(
    find.byType(WidgetsApp),
    matchesGoldenFile('goldens/$name.png'),
  );
}
''';
}
