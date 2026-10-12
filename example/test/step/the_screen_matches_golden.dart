import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: the screen matches golden {'initial_counter'}
///
/// The path is resolved relative to the generated `*_test.dart` file, so the
/// golden for `test/sample.feature` is `test/goldens/initial_counter.png`.
Future<void> theScreenMatchesGolden(WidgetTester tester, String name) =>
    expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
