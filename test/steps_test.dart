import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testing_data.dart';

void main() {
  test('simplest feature file parses', () {
    const path = 'test';
    const expectedStep = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> TheAppIsRunning(WidgetTester tester) async {
  throw 'not implemented';
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
  throw 'not implemented';
}
''',
      '''
import 'package:flutter_test/flutter_test.dart';

Future<void> ISeeTextAndIcon(WidgetTester tester, dynamic param1, dynamic param2) async {
  throw 'not implemented';
}
''',
    ];

    final feature = FeatureFile(path: '$path.feature', input: featureFile);
    expect(feature.getStepFiles().length, 2);
    expect(feature.getStepFiles().first.dartContent, expectedSteps.first);
    expect(feature.getStepFiles().last.dartContent, expectedSteps.last);
  });
}
