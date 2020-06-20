import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('I See Icon pre-built step generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I see {Icons.add} icon
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';

Future<void> iSeeIcon(WidgetTester tester, IconData icon) async {
  expect(find.byIcon(icon), findsOneWidget);
}
''';

    final feature =
        FeatureFile(path: '$path.feature', package: path, input: featureFile);

    expect(feature.getStepFiles().single.dartContent, expectedSteps);
  });
}
