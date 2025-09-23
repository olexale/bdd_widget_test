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
    this.includeIntegrationTestImport = false,
    this.includeIntegrationTestBinding = false,
    this.existingSteps = const <String, String>{},
    this.generatorOptions = const GeneratorOptions(),
  }) : _lines = _prepareLines(
         input.split('\n').map((line) => line.trim()).map(BddLine.new),
       ),
       hookFile =
           generatorOptions.addHooks
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

    _stepFiles =
        _lines
            .where(
              (line) =>
                  line.type == LineType.step ||
                  line.type == LineType.dataTableStep,
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

  final bool includeIntegrationTestImport;
  final bool includeIntegrationTestBinding;

  final List<BddLine> _lines;
  final Map<String, String> existingSteps;
  final GeneratorOptions generatorOptions;
  final HookFile? hookFile;

  String get dartContent => generateFeatureDart(
    _lines,
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

  static List<BddLine> _prepareLines(Iterable<BddLine> input) {
    final inputList = input.toList(growable: false);
    final lines = inputList
        .mapIndexed(
          (index, bddLine) {
            final isStep = bddLine.type == LineType.step;
            final isNextTable = data_table_parser.isTable(
              lines: inputList,
              index: index + 1,
            );
            final isExamplesTable =
                isNextTable &&
                data_table_parser.isDataTableExamples(
                  lines: inputList,
                  index: index,
                );
            return isStep && isNextTable && !isExamplesTable
                ? BddLine.fromRawValue(
                  LineType.dataTableStep,
                  bddLine.rawLine,
                )
                : bddLine;
          },
        )
        .toList(growable: false);

    final headers = lines
        .takeWhile((value) => value.type != LineType.feature)
        .where((value) => value.type == LineType.unknown)
        .foldIndexed(
          // this removes empty line dupicates
          <BddLine>[],
          (index, headers, line) => [
            ...headers,
            if (index == 0 && line.rawLine != '\n' && line.rawLine.isNotEmpty)
              line
            else if (headers.isNotEmpty && headers.last.rawLine != line.rawLine)
              line,
          ],
        );
    final steps = lines.where((value) => value.type != LineType.unknown);
    return [...headers, ...steps];
  }
}
