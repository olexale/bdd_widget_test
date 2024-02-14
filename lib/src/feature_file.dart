import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/data_table_parser.dart'
    as data_table_parser;
import 'package:bdd_widget_test/src/feature_generator.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/hook_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/util/common.dart';
import 'package:bdd_widget_test/src/util/constants.dart';
import 'package:collection/collection.dart';

class FeatureFile {
  FeatureFile({
    required this.featureDir,
    required this.package,
    required String input,
    this.isIntegrationTest = false,
    this.includeIntegrationTestBinding = true,
    this.existingSteps = const <String, String>{},
    this.generatorOptions = const GeneratorOptions(),
  })  : _lines = _prepareLines(
          input.split('\n').map((line) => line.trim()).map(BddLine.new),
        ),
        hookFile = generatorOptions.addHooks
            ? HookFile.create(
                featureDir: featureDir,
                package: package,
                generatorOptions: generatorOptions,
              )
            : null {
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
        .where(
          (line) =>
              line.type == LineType.step || line.type == LineType.dataTableStep,
        )
        .map(
          (bddLine) => StepFile.create(
            featureDir,
            package,
            bddLine,
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
  /// Whether to include the integration test binding in the generated test for integration tests. Defaults to true.
  final bool includeIntegrationTestBinding;
  final List<BddLine> _lines;
  final Map<String, String> existingSteps;
  final GeneratorOptions generatorOptions;
  final HookFile? hookFile;

  String get dartContent => generateFeatureDart(
        lines: _lines,
        steps: getStepFiles(),
        testMethodName: generatorOptions.testMethodName,
        testerType: _testerType,
        testerName: _testerName,
        isIntegrationTest: isIntegrationTest,
        includeIntegrationTestBinding: includeIntegrationTestBinding,
        hookFile: hookFile,
      );

  List<StepFile> getStepFiles() => _stepFiles;

  static List<BddLine> _prepareLines(Iterable<BddLine> input) {
    final lines = input.mapIndexed(
      (index, bddLine) {
        final isStep = bddLine.type == LineType.step;
        final hasExamplesFormat = data_table_parser.hasExamplesFormat(
          bddLine: bddLine,
        );
        final isNextTable = data_table_parser.isTable(
          lines: input.toList(),
          index: index + 1,
        );
        if (isStep && !hasExamplesFormat && isNextTable) {
          return BddLine.fromRawValue(LineType.dataTableStep, bddLine.rawLine);
        } else {
          return bddLine;
        }
      },
    );

    final headers = lines.takeWhile((value) => value.type == LineType.unknown);
    final steps = lines
        .skip(headers.length)
        .where((value) => value.type != LineType.unknown);
    return [...headers, ...steps];
  }
}
