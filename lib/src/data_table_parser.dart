import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/scenario_generator.dart';

bool hasBddDataTable(List<BddLine> lines) {
  for (var index = 0; index < lines.length; index++) {
    final isStep = lines[index].type == LineType.step;
    final isNextLineTable = isNextTable(lines: lines, index: index + 1);
    final isExamplesFormatted = hasExamplesFormat(bddLine: lines[index]);
    if (isStep && isNextLineTable && !isExamplesFormatted) {
      return true;
    }
  }
  return false;
}

Iterable<BddLine> replaceDataTables(List<BddLine> lines) sync* {
  for (var index = 0; index < lines.length; index++) {
    final isStep = lines[index].type == LineType.step;
    final isNextLineTable = isNextTable(lines: lines, index: index + 1);
    if (isStep && isNextLineTable) {
      if (!hasExamplesFormat(bddLine: lines[index])) {
// Cucumber data table
        final text = lines[index].value;
        final table = List<List<String>>.empty(growable: true);
        do {
          table.add(_createRow(bddLine: lines[++index]));
        } while (isNextTable(lines: lines, index: index + 1));
        yield BddLine.fromValue(
          LineType.step,
          '$text {const bdd.DataTable($table)}',
        );
      } else {
// Data table formatted as examples
        final dataTable = [lines[index]];
        do {
          dataTable.add(lines[++index]);
        } while (index + 1 < lines.length &&
            lines[index + 1].type == LineType.examples);
        final data = generateScenariosFromScenaioOutline([
// pretend to be an Example section to re-use some logic
          BddLine.fromValue(LineType.exampleTitle, ''),
          ...dataTable,
        ]);

        for (final item in data) {
          yield item[1];
        }
      }
    } else {
      yield lines[index];
    }
  }
}

bool isNextTable({
  required List<BddLine> lines,
  required int index,
}) =>
    index < lines.length && _isTable(bddLine: lines[index]);

bool _isTable({required BddLine bddLine}) => bddLine.type == LineType.examples;

bool hasExamplesFormat({required BddLine bddLine}) =>
    examplesRegExp.allMatches(bddLine.rawLine).isNotEmpty;

List<String> _createRow({
  required BddLine bddLine,
}) =>
    List<String>.unmodifiable(
      bddLine.value
          .split('|')
          .map((example) => example.trim())
          .takeWhile((value) => value.isNotEmpty)
          .toList(),
    );
