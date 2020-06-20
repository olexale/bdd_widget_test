import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing_data.dart';

void main() {
  test('simplest feature file parses', () {
    const path = 'test';
    const expectedStep = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> TheAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
}
''';

    final feature = FeatureFile(path: '$path.feature', input: minimalFeatureFile);
    expect(feature.getStepFiles().length, 1);
    expect(feature.getStepFiles().first.dartContent, expectedStep);
  });

  test('Feature file generates two steps', () {
    const path = 'test';
    const expectedSteps = [
      '''
import 'package:flutter_test/flutter_test.dart';

Future<void> TheAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
}
''',
      '''
import 'package:flutter_test/flutter_test.dart';

Future<void> ISeeText(WidgetTester tester, dynamic param1) async {
  expect(find.text(param1), findsOneWidget);
}
''',
      '''
import 'package:flutter_test/flutter_test.dart';

Future<void> ISeeIcon(WidgetTester tester, dynamic param1) async {
  expect(find.byIcon(param1), findsOneWidget);
}
''',
    ];

    final feature = FeatureFile(path: '$path.feature', input: featureFile);

    expect(feature.getStepFiles().length, expectedSteps.length);

    for (var i = 0; i < expectedSteps.length; i++) {
      expect(feature.getStepFiles()[i].dartContent, expectedSteps[i]);
    }
  });
}
