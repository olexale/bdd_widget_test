import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/feature_generator.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/util/common.dart';
import 'package:bdd_widget_test/src/util/constants.dart';

class FeatureFile {
  FeatureFile({
    required this.featureDir,
    required this.package,
    required String input,
    this.isIntegrationTest = false,
    this.existingSteps = const <String, String>{},
    this.generatorOptions = const GeneratorOptions(),
  }) : _lines = _prepareLines(
          input.split('\n').map((line) => line.trim()).map(BddLine.new),
        ) {
    _testerType = parseCustomTagFromFeatureTagLine(
      _lines,
      generatorOptions.testerType,
      testerTypeTag,
    );

    _testerName = parseCustomTagFromFeatureTagLine(
      _lines,
      generatorOptions.testerName,
      testerNameTag,
    );

    _stepFiles = _lines
        .where((line) => line.type == LineType.step)
        .map(
          (e) => StepFile.create(
            featureDir,
            package,
            e.value,
            existingSteps,
            generatorOptions,
            _testerType,
            _testerName,
          ),
        )
        .toList();
  }

  late List<StepFile> _stepFiles;
  late String _testerType;
  late String _testerName;

  final String featureDir;
  final String package;
  final bool isIntegrationTest;
  final List<BddLine> _lines;
  final Map<String, String> existingSteps;
  final GeneratorOptions generatorOptions;

  String get dartContent => generateFeatureDart(
        _lines,
        getStepFiles(),
        generatorOptions.testMethodName,
        _testerType,
        _testerName,
        isIntegrationTest,
      );

  List<StepFile> getStepFiles() => _stepFiles;

  static List<BddLine> _prepareLines(Iterable<BddLine> input) {
    final headers = input.takeWhile((value) => value.type == LineType.unknown);
    final lines = input
        .skip(headers.length)
        .where((value) => value.type != LineType.unknown);
    return [...headers, ...lines];
  }
}
