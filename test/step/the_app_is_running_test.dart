import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

import '../util/testing_data.dart';

void main() {
  test('The app is running pre-built step generated', () {
    const path = 'test';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';
import 'package:$path/main.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
}
''';

    final feature = FeatureFile(
      featureDir: '$path.feature',
      package: path,
      input: minimalFeatureFile,
    );

    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedSteps,
    );
  });
}
