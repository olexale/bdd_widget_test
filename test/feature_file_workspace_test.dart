import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:test/test.dart';

// In a real workspace build, `featureDir` is package-relative (e.g.
// "test/features") and `packageRoot` is the absolute package directory with no
// trailing slash (resolvePackageRoot normalizes it). Generated paths must stay
// INSIDE the package.
void main() {
  const packageRoot = '/ws/app_a';
  const featureDir = 'test/features';
  const input = '''
Feature: F
    Scenario: S
        Given the app is running
''';

  group('workspace paths stay inside the package', () {
    test('relative hook folder writes next to the feature file', () {
      final feature = FeatureFile(
        featureDir: featureDir,
        package: 'app_a',
        input: input,
        generatorOptions: const GeneratorOptions(
          addHooks: true,
          hookFolderName: './hook',
        ),
        packageRoot: packageRoot,
      );

      expect(
        feature.hookFile!.fileName,
        '/ws/app_a/test/features/hook/hooks.dart',
      );
      expect(feature.hookFile!.import, './hook/hooks.dart');
    });

    test('test-relative hook folder resolves under <packageRoot>/test', () {
      final feature = FeatureFile(
        featureDir: featureDir,
        package: 'app_a',
        input: input,
        generatorOptions: const GeneratorOptions(
          addHooks: true,
          hookFolderName: 'hook',
          relativeToTestFolder: true,
        ),
        packageRoot: packageRoot,
      );

      expect(feature.hookFile!.fileName, '/ws/app_a/test/hook/hooks.dart');
      expect(feature.hookFile!.import, '../hook/hooks.dart');
    });

    test('relative step folder writes next to the feature file', () {
      final feature = FeatureFile(
        featureDir: featureDir,
        package: 'app_a',
        input: input,
        generatorOptions: const GeneratorOptions(stepFolderName: './my_steps'),
        packageRoot: packageRoot,
      );

      final step = feature.getStepFiles().whereType<NewStepFile>().single;
      expect(step.import, './my_steps/the_app_is_running.dart');
      expect(
        step.filename,
        '/ws/app_a/test/features/my_steps/the_app_is_running.dart',
      );
      expect(step.filename.startsWith('/ws/app_a/'), isTrue);
    });

    test('test-relative step folder import is package-relative', () {
      final feature = FeatureFile(
        featureDir: featureDir,
        package: 'app_a',
        input: input,
        generatorOptions: const GeneratorOptions(
          stepFolderName: 'step',
          relativeToTestFolder: true,
        ),
        packageRoot: packageRoot,
      );

      final step = feature.getStepFiles().whereType<NewStepFile>().single;
      expect(step.import, '../step/the_app_is_running.dart');
      expect(step.filename, '/ws/app_a/test/step/the_app_is_running.dart');
      // Must never escape the package.
      expect(step.filename.startsWith('/ws/app_a/'), isTrue);
    });

    test('null packageRoot preserves original (non-workspace) behavior', () {
      final feature = FeatureFile(
        featureDir: featureDir,
        package: 'app_a',
        input: input,
        generatorOptions: const GeneratorOptions(
          addHooks: true,
          hookFolderName: './hook',
        ),
      );

      expect(feature.hookFile!.import, './hook/hooks.dart');
      expect(feature.hookFile!.fileName, 'test/features/hook/hooks.dart');
    });
  });
}
