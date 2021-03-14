import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('External step will not be generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Given I have an external step
    ''';

    final feature = FeatureFile(
      featureDir: '$path.feature',
      package: path,
      input: featureFile,
      generatorOptions: const GeneratorOptions(
          externalSteps: ['package:some_package/i_have_an_external_step.dart']),
    );

    expect(
      feature.getStepFiles().whereType<NewStepFile>().isEmpty,
      true,
    );
    expect(
      feature.getStepFiles().whereType<ExistingStepFile>().isEmpty,
      true,
    );
    expect(
      feature.getStepFiles().whereType<ExternalStepFile>().length,
      1,
    );
  });
}
