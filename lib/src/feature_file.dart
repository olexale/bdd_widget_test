import 'package:bdd_widget_test/src/feature_generator.dart';
import 'package:bdd_widget_test/src/feature_model.dart';
import 'package:bdd_widget_test/src/feature_parser.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/hook_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/util/common.dart';
import 'package:bdd_widget_test/src/util/constants.dart';

class FeatureFile {
  FeatureFile({
    required this.featureDir,
    required this.package,
    required String input,
    this.includeIntegrationTestImport = false,
    this.includeIntegrationTestBinding = false,
    this.existingSteps = const <String, String>{},
    this.generatorOptions = const GeneratorOptions(),
    this.packageRoot,
  }) : _model = parseFeatureFile(input, featureDir),
       hookFile = generatorOptions.addHooks
           ? HookFile.create(
               featureDir: featureDir,
               package: package,
               generatorOptions: generatorOptions,
               packageRoot: packageRoot,
             )
           : null {
    _testerType = parseCustomTagValue(
      _model.allTagLines,
      generatorOptions.testerType,
      testerTypeTag,
    );

    _testerName = parseCustomTagValue(
      _model.allTagLines,
      generatorOptions.testerName,
      testerNameTag,
    );

    _stepFiles = _model.allSteps
        .map(
          (step) => StepFile.create(
            featureDir,
            package,
            step,
            existingSteps,
            generatorOptions,
            _testerType,
            _testerName,
            packageRoot,
          ),
        )
        .toList();
  }

  late List<StepFile> _stepFiles;
  late String _testerType;
  late String _testerName;

  final String featureDir;
  final String package;
  final String? packageRoot;

  final bool includeIntegrationTestImport;
  final bool includeIntegrationTestBinding;

  final FeatureFileModel _model;
  final Map<String, String> existingSteps;
  final GeneratorOptions generatorOptions;
  final HookFile? hookFile;

  String get dartContent => generateFeatureDart(
    _model,
    getStepFiles(),
    generatorOptions.testMethodName,
    _testerType,
    _testerName,
    includeIntegrationTestBinding,
    includeIntegrationTestImport,
    hookFile,
    generatorOptions,
  );

  List<StepFile> getStepFiles() => _stepFiles;
}
