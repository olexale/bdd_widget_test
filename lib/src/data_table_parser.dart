import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/scenario_generator.dart';

bool hasBddDataTable(List<BddLine> lines) {
  for (var index = 0; index < lines.length; index++) {
    final isStep = lines[index].type == LineType.step ||
        lines[index].type == LineType.dataTableStep;
    final isNextLineTable = isTable(lines: lines, index: index + 1);
    final isExamplesFormatted = hasExamplesFormat(bddLine: lines[index]);
    if (isStep && isNextLineTable && !isExamplesFormatted) {
      return true;
    }
  }
  return false;
}

Iterable<BddLine> replaceDataTables(List<BddLine> lines) sync* {
  for (var index = 0; index < lines.length; index++) {
    final isStep = lines[index].type == LineType.step ||
        lines[index].type == LineType.dataTableStep;
    final isNextLineTable = isTable(lines: lines, index: index + 1);
    if (isStep && isNextLineTable) {
      final table = !hasExamplesFormat(bddLine: lines[index])
          ? _createCucumberDataTable(lines: lines, index: index)
          : _createDataTableFromExamples(lines: lines, index: index);
      yield* table;
      // skip the parsed table
      while (isTable(lines: lines, index: index + 1)) {
        index++;
      }
    } else {
      yield lines[index];
    }
  }
}

bool isTable({
  required List<BddLine> lines,
  required int index,
}) =>
    index < lines.length && lines[index].type == LineType.examples;

bool hasExamplesFormat({required BddLine bddLine}) =>
    examplesRegExp.firstMatch(bddLine.rawLine) != null;

List<String> _createRow({
  required BddLine bddLine,
}) =>
    bddLine.value
        .split('|')
        .map((example) => example.trim())
        .takeWhile((value) => value.isNotEmpty)
        .toList();

Iterable<BddLine> _createCucumberDataTable({
  required List<BddLine> lines,
  required int index,
}) sync* {
  final text = lines[index].value;
  final table = <List<String>>[];
  do {
    table.add(_createRow(bddLine: lines[++index]));
  } while (isTable(lines: lines, index: index + 1));
  yield BddLine.fromValue(
    LineType.dataTableStep,
    '$text {const bdd.DataTable($table)}',
  );
}

Iterable<BddLine> _createDataTableFromExamples({
  required List<BddLine> lines,
  required int index,
}) sync* {
  final dataTable = [lines[index]];
  do {
    dataTable.add(lines[++index]);
  } while (
      index + 1 < lines.length && lines[index + 1].type == LineType.examples);
  final data = generateScenariosFromScenarioOutline([
    // pretend to be an Example section to re-use some logic
    BddLine.fromValue(LineType.exampleTitle, ''),
    ...dataTable,
  ]);

  for (final item in data) {
    yield item[1];
  }
}
