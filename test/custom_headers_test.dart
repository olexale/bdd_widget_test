import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

void main() {
  test('Custom imports are added to generated steps', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        When I invoke test
    ''';

    const expectedSteps = '''
import 'package:flutter_test/flutter_test.dart';
// My custom classes
import 'package:custom_package_a/custom_class_a.dart';
import 'package:custom_package_b/custom_class_b.dart';

/// Usage: I invoke test
Future<void> iInvokeTest(WidgetTester tester) async {
  throw UnimplementedError();
}
''';

    final feature = FeatureFile(
      featureDir: '$path.feature',
      package: path,
      input: featureFile,
      generatorOptions: const GeneratorOptions(
        customHeaders: [
          "import 'package:flutter_test/flutter_test.dart';",
          '// My custom classes',
          "import 'package:custom_package_a/custom_class_a.dart';",
          "import 'package:custom_package_b/custom_class_b.dart';",
        ],
      ),
    );

    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedSteps,
    );
  });

  test('Custom imports with data tables work correctly', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
  Scenario: Testing scenario
    Given the following data
    | column1 | column2 |
    | value1  | value2  |
    ''';

    const expectedSteps = '''
import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:custom_package/custom_class.dart';

/// Usage: the following data
Future<void> theFollowingData(WidgetTester tester, bdd.DataTable dataTable) async {
  throw UnimplementedError();
}
''';

    final feature = FeatureFile(
      featureDir: '$path.feature',
      package: path,
      input: featureFile,
      generatorOptions: const GeneratorOptions(
        customHeaders: [
          "import 'package:custom_package/custom_class.dart';",
        ],
      ),
    );

    expect(
      feature.getStepFiles().whereType<NewStepFile>().single.dartContent,
      expectedSteps,
    );
  });
}
