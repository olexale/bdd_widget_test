import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:path/path.dart' as p;

class StepFile {
  StepFile(String featureDir, this.package, this.line)
      : filename = p.join(featureDir, 'step', '${getStepFilename(line)}.dart'),
        import = p.join('.', 'step', '${getStepFilename(line)}.dart');

  final String filename;
  final String import;
  final String package;
  final String line;

  String get dartContent => generateStepDart(package, line);
}
