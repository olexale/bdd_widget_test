import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/scenario_generator.dart';

Iterable<BddLine> replaceDataTables(List<BddLine> lines) sync* {
  var reachedExamples = false;
  var i = 0;
  while (i < lines.length) {
    if (lines[i].type == LineType.exampleTitle) {
      reachedExamples = true;
    }
    if (reachedExamples) {
      yield lines[i++];
      continue;
    }
    if (i + 1 < lines.length && _foundDataTable(lines, i)) {
      final dataTable = [
        lines[i],
        ...lines.skip(i + 1).takeWhile((l) => l.type == LineType.examples),
      ];
      final data = generateScenariosFromScenaioOutline([
        // pretend to be an Example section to re-use some logic
        BddLine.fromValue(LineType.exampleTitle, ''),
        ...dataTable,
      ]);
      for (final item in data) {
        yield item[1];
      }
      i += dataTable.length;
      continue;
    }
    yield lines[i++];
  }
}

bool _foundDataTable(List<BddLine> lines, int index) =>
    lines[index].type == LineType.step &&
    lines[index + 1].type == LineType.examples;
