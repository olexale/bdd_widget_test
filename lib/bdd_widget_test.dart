import 'package:bdd_widget_test/src/existing_steps.dart';
import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/hook_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/util/dart_formatter.dart';
import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

Builder featureBuilder(BuilderOptions options) => FeatureBuilder(
      GeneratorOptions.fromMap(options.config),
    );

class FeatureBuilder implements Builder {
  FeatureBuilder(this.generatorOptions);

  final GeneratorOptions generatorOptions;

  @override
  Future<void> build(BuildStep buildStep) async {
    final options = await _prepareOptions();

    final inputId = buildStep.inputId;
    final contents = await buildStep.readAsString(inputId);

    final featureDir = p.dirname(inputId.path);
    final isIntegrationTest =
        inputId.pathSegments.contains('integration_test') &&
            _hasIntegrationTestDevDependency();

    final feature = FeatureFile(
      featureDir: featureDir,
      package: inputId.package,
      existingSteps: getExistingStepSubfolders(featureDir, options),
      input: contents,
      generatorOptions: options,
      includeIntegrationTestImport: isIntegrationTest,
      includeIntegrationTestBinding:
          isIntegrationTest && generatorOptions.includeIntegrationTestBinding,
    );

    final featureDart = inputId.changeExtension('_test.dart');
    await buildStep.writeAsString(
      featureDart,
      formatDartCode(feature.dartContent),
    );

    final steps = feature.getStepFiles().whereType<NewStepFile>().map(
          (e) =>
              _createFileRecursively(e.filename, formatDartCode(e.dartContent)),
        );
    await Future.wait(steps);

    final hookFile = feature.hookFile;
    if (hookFile != null) {
      await _createFileRecursively(hookFile.fileName, hookFileContent);
    }
  }

  Future<GeneratorOptions> _prepareOptions() async {
    final fileOptions = fs.file('bdd_options.yaml').existsSync()
        ? readFromUri(Uri.file('bdd_options.yaml'))
        : null;
    final mergedOptions = fileOptions != null
        ? merge(generatorOptions, fileOptions)
        : generatorOptions;
    final options = await flattenOptions(mergedOptions);
    return options;
  }

  Future<void> _createFileRecursively(String filename, String content) async {
    final f = fs.file(filename);
    if (f.existsSync()) {
      return;
    }
    final file = await f.create(recursive: true);
    await file.writeAsString(content);
  }

  bool _hasIntegrationTestDevDependency() {
    if (fs.file('pubspec.yaml').existsSync()) {
      final fileContent = fs.file('pubspec.yaml').readAsStringSync();
      final pubspec = loadYaml(fileContent) as YamlMap;
      final devDependencies = pubspec['dev_dependencies'] as YamlMap?;
      return devDependencies?.containsKey('integration_test') ?? false;
    }
    return false;
  }

  @override
  final buildExtensions = const {
    '.feature': ['_test.dart'],
  };
}
