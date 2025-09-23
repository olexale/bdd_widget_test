import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/scenario_generator.dart';

bool hasBddDataTable(List<BddLine> lines) {
  for (var index = 0; index < lines.length; index++) {
    final isStep =
        lines[index].type == LineType.step ||
        lines[index].type == LineType.dataTableStep;
    final isNextLineTable = isTable(lines: lines, index: index + 1);
    if (isStep &&
        isNextLineTable &&
        !isDataTableExamples(lines: lines, index: index)) {
      return true;
    }
  }
  return false;
}

Iterable<BddLine> replaceDataTables(List<BddLine> lines) sync* {
  for (var index = 0; index < lines.length; index++) {
    final isStep =
        lines[index].type == LineType.step ||
        lines[index].type == LineType.dataTableStep;
    final isNextLineTable = isTable(lines: lines, index: index + 1);
    if (isStep && isNextLineTable) {
      final table =
          isDataTableExamples(lines: lines, index: index)
              ? _createDataTableFromExamples(lines: lines, index: index)
              : _createCucumberDataTable(lines: lines, index: index);
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
}) => index < lines.length && lines[index].type == LineType.examples;

bool hasExamplesFormat({required BddLine bddLine}) =>
    examplesRegExp.firstMatch(bddLine.rawLine) != null;

/// Determines if the data table following the step at [index]
/// is intended to be used as Examples (parameter expansion) rather than
/// as a cucumber data table argument.
///
/// Heuristic: if the step contains placeholders like `<name>` and the first
/// row of the following table contains headers that include ALL of those
/// placeholder names, then treat the table as Examples; otherwise, treat it
/// as a cucumber data table.
bool isDataTableExamples({
  required List<BddLine> lines,
  required int index,
}) {
  final step = lines[index];
  if (!hasExamplesFormat(bddLine: step)) return false;
  final nextIsTable = isTable(lines: lines, index: index + 1);
  if (!nextIsTable) return false;

  final placeholders =
      examplesRegExp
          .allMatches(step.rawLine)
          .map((m) => m.group(1)!.trim())
          .where((e) => e.isNotEmpty)
          .toSet();
  if (placeholders.isEmpty) return false;

  // Use the first table row as headers
  final headers = _createRow(bddLine: lines[index + 1]).toSet();
  if (headers.isEmpty) return false;

  // Only treat as examples when all placeholders are present in headers
  return placeholders.every(headers.contains);
}

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
  } while (index + 1 < lines.length &&
      lines[index + 1].type == LineType.examples);
  final data = generateScenariosFromScenarioOutline([
    // pretend to be an Example section to re-use some logic
    BddLine.fromValue(LineType.exampleTitle, ''),
    ...dataTable,
  ]);

  for (final item in data) {
    yield item[1];
  }
}
