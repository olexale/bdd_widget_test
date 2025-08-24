import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

void main() {
  test('Existing step will not be generated', () {
    const path = 'test';
    const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Given I have a step
    ''';

    final feature = FeatureFile(
      featureDir: '$path.feature',
      package: path,
      input: featureFile,
      existingSteps: {'i_have_a_step.dart': 'step'},
    );

    expect(
      feature.getStepFiles().whereType<NewStepFile>().isEmpty,
      true,
    );
    expect(
      feature.getStepFiles().whereType<ExternalStepFile>().isEmpty,
      true,
    );
    expect(
      feature.getStepFiles().whereType<ExistingStepFile>().length,
      1,
    );
  });
}
