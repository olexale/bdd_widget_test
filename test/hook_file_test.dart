import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:test/test.dart';

void main() {
  test('Hook file generation ', () {
    final feature = FeatureFile(
      featureDir: 'test/sub-feature/feature',
      package: 'bdd_feature',
      input: '',
      generatorOptions: const GeneratorOptions(
        addHooks: true,
      ),
    );
    expect(feature.hookFile, isNotNull);
    expect(
      feature.hookFile?.fileName,
      'test/sub-feature/feature/./hook/hooks.dart',
    );
    expect(feature.hookFile?.import, './hook/hooks.dart');
  });

  test('Disable hook file generation ', () {
    final feature = FeatureFile(
      featureDir: 'test/sub-feature/feature',
      package: 'bdd_feature',
      input: '',
    );
    expect(feature.hookFile, isNull);
  });
}
