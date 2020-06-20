import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('The app is running pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Given the app is running
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';
import 'package:$path/main.dart';

Future<void> TheAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
}
''';

    final feature =
        FeatureFile(path: '$path.feature', package: path, input: featureFile);

    expect(feature.getStepFiles().single.dartContent, expectedSteps);
  });
}
