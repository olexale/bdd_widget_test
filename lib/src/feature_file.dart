import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/feature_generator.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:path/path.dart' as p;

class FeatureFile {
  FeatureFile({
    this.path,
    String input,
  }) : _lines = input
            .split('\n')
            .map((line) => line.trim())
            .map((line) => BddLine(line))
            .where((line) => line.type != LineType.unknown)
            .toList();

  final String path;
  final List<BddLine> _lines;

  String get dartContent => generateFeatureDart(_lines, getStepFiles());

  List<StepFile> getStepFiles() {
    return _lines
        .where((line) => line.type == LineType.step)
        .map((e) => StepFile(p.dirname(path), e.value))
        .toList();
  }
}
