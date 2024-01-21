import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/constants.dart';
import 'package:path/path.dart' as p;

abstract class StepFile {
  const StepFile._(this.import);
  final String import;

  static StepFile create(
    String featureDir,
    String package,
    String line,
    Map<String, String> existingSteps,
    GeneratorOptions generatorOptions,
    String testerTypeTagValue,
    String testerNameTagValue,
    bool hasDataTable,
  ) {
    final file = '${getStepFilename(line)}.dart';

    if (existingSteps.containsKey(file)) {
      final import =
          p.join('.', existingSteps[file], file).replaceAll(r'\', '/');
      return ExistingStepFile._(import);
    }

    final externalStep = generatorOptions.externalSteps
        .firstWhere((l) => l.contains(file), orElse: () => '');
    if (externalStep.isNotEmpty) {
      return ExternalStepFile._(externalStep);
    }

    if (generatorOptions.stepFolder.startsWith('./') ||
        generatorOptions.stepFolder.startsWith('../')) {
      final import =
          p.join(generatorOptions.stepFolder, file).replaceAll(r'\', '/');
      final filename = p.join(featureDir, generatorOptions.stepFolder, file);
      return NewStepFile._(
        import,
        filename,
        package,
        line,
        testerTypeTagValue,
        testerNameTagValue,
        hasDataTable,
      );
    }

    final pathToTestFolder = p.relative(testFolderName, from: featureDir);
    final import = p
        .join(pathToTestFolder, generatorOptions.stepFolder, file)
        .replaceAll(r'\', '/');
    final filename = p.join(testFolderName, generatorOptions.stepFolder, file);
    return NewStepFile._(
      import,
      filename,
      package,
      line,
      testerTypeTagValue,
      testerNameTagValue,
      hasDataTable,
    );
  }
}

class NewStepFile extends StepFile {
  const NewStepFile._(
    super.import,
    this.filename,
    this.package,
    this.line,
    this.testerType,
    this.testerName,
    this.hasDataTable,
  ) : super._();

  final String package;
  final String line;
  final String filename;
  final String testerType;
  final String testerName;
  final bool hasDataTable;
  String get dartContent => generateStepDart(
        package,
        line,
        testerType,
        testerName,
        hasDataTable,
      );
}

class ExistingStepFile extends StepFile {
  const ExistingStepFile._(super.import) : super._();
}

class ExternalStepFile extends StepFile {
  const ExternalStepFile._(super.import) : super._();
}
