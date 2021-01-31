Create a `*.feature` file in the `test` folder. The minimal file might be:
```
Feature: Counter
    Scenario: Initial counter value is 0
        Given the app is running
        Then I see {'0'} text
```

Run
```
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

The output Dart file would be:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import './step/the_app_is_running.dart';
import './step/i_see_text.dart';

void main() {
  group('Counter app', () {
    testWidgets('Initial counter value is 0', (WidgetTester tester) async {
      await theAppIsRunning(tester);
      await iSeeText(tester, '0');
    });
  });
}
```

Refer to `step` folder to get familiar with steps implementation.
