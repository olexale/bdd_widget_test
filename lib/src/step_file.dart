import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
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
  ) {
    final file = '${getStepFilename(line)}.dart';

    if (existingSteps.containsKey(file)) {
      final import =
          p.join('.', existingSteps[file], file).replaceAll('\\', '/');
      return ExistingStepFile._(import);
    }

    final externalStep = generatorOptions.externalSteps
        .firstWhere((l) => l.contains(file), orElse: () => '');
    if (externalStep.isNotEmpty) {
      return ExternalStepFile._(externalStep);
    }

    final import =
        p.join('.', generatorOptions.stepFolder, file).replaceAll('\\', '/');
    final filename = p.join(featureDir, generatorOptions.stepFolder, file);
    return NewStepFile._(import, filename, package, line);
  }
}

class NewStepFile extends StepFile {
  const NewStepFile._(String import, this.filename, this.package, this.line)
      : super._(import);

  final String package;
  final String line;
  final String filename;

  String get dartContent => generateStepDart(package, line);
}

class ExistingStepFile extends StepFile {
  const ExistingStepFile._(String import) : super._(import);
}

class ExternalStepFile extends StepFile {
  const ExternalStepFile._(String import) : super._(import);
}
