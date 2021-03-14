import 'package:bdd_widget_test/src/constants.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:path/path.dart' as p;

abstract class StepFile {
  const StepFile._(this.import, [this.filename]);
  final String import;
  final String filename;

  static StepFile create(
    String featureDir,
    String package,
    String line,
    Map<String, String> existingSteps,
    List<String> externalSteps,
  ) {
    final file = '${getStepFilename(line)}.dart';

    if (existingSteps.containsKey(file)) {
      final import =
          p.join('.', existingSteps[file], file).replaceAll('\\', '/');
      return ExistingStepFile._(import);
    }

    final externalStep =
        externalSteps.firstWhere((l) => l.contains(file), orElse: () => '');
    if (externalStep.isNotEmpty) {
      return ExternalStepFile._(externalStep);
    }

    final import = p.join('.', stepFolderName, file).replaceAll('\\', '/');
    final filename = p.join(featureDir, stepFolderName, file);
    return NewStepFile._(import, filename, package, line);
  }
}

class NewStepFile extends StepFile {
  const NewStepFile._(String import, String filename, this.package, this.line)
      : super._(import, filename);

  final String package;
  final String line;

  String get dartContent => generateStepDart(package, line);
}

class ExistingStepFile extends StepFile {
  const ExistingStepFile._(String import) : super._(import);
}

class ExternalStepFile extends StepFile {
  const ExternalStepFile._(String import) : super._(import);
}
