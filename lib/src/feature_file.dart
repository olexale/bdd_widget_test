import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/feature_generator.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:path/path.dart' as p;

class FeatureFile {
  FeatureFile({
    this.path,
    this.package,
    String input,
  }) : _lines = _prepareLines(input
            .split('\n')
            .map((line) => line.trim())
            .map((line) => BddLine(line)));

  final String path;
  final String package;
  final List<BddLine> _lines;

  String get dartContent => generateFeatureDart(_lines, getStepFiles());

  List<StepFile> getStepFiles() => _lines
      .where((line) => line.type == LineType.step)
      .map((e) => StepFile(p.dirname(path), package, e.value))
      .toList();

  static List<BddLine> _prepareLines(Iterable<BddLine> input) {
    final headers = input.takeWhile((value) => value.type == LineType.unknown);
    final lines = input
        .skip(headers.length)
        .where((value) => value.type != LineType.unknown);
    return [...headers, ...lines];
  }
}
