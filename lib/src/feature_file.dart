import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/feature_generator.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/step_file.dart';

class FeatureFile {
  FeatureFile({
    this.featureDir,
    this.package,
    this.existingSteps = const <String, String>{},
    this.generatorOptions = const GeneratorOptions(),
    String input,
  }) : _lines = _prepareLines(input
            .split('\n')
            .map((line) => line.trim())
            .map((line) => BddLine(line))) {
    _stepFiles = _lines
        .where((line) => line.type == LineType.step)
        .map((e) => StepFile.create(
              featureDir,
              package,
              e.value,
              existingSteps,
              generatorOptions.externalSteps ?? [],
            ))
        .toList();
  }

  final String featureDir;
  final String package;
  final List<BddLine> _lines;
  final Map<String, String> existingSteps;
  final GeneratorOptions generatorOptions;
  List<StepFile> _stepFiles;

  String get dartContent => generateFeatureDart(
        _lines,
        getStepFiles(),
        generatorOptions.testMethodName ?? defaultTestName,
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
