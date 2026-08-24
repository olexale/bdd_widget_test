import 'package:bdd_widget_test/src/feature_model.dart';
import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/scenario_generator.dart';

/// Whether the table attached to a step is meant as Examples (repeating the
/// step once per row) rather than as a cucumber data table argument.
///
/// Heuristic: if the step contains placeholders like `<name>` and the header
/// row names ALL of them, treat the table as Examples; otherwise treat it as a
/// cucumber data table.
bool isExamplesTable(String stepText, List<List<String>> table) {
  final placeholders = examplesRegExp
      .allMatches(stepText)
      .map((match) => match.group(1)!.trim())
      .where((placeholder) => placeholder.isNotEmpty)
      .toSet();
  if (placeholders.isEmpty) {
    return false;
  }
  final headers = table.isEmpty ? const <String>{} : table.first.toSet();
  if (headers.isEmpty) {
    return false;
  }
  return placeholders.every(headers.contains);
}

/// Resolves every step into the text of the call to generate for it, folding
/// in whatever table was written underneath.
List<String> resolveSteps(Iterable<Step> steps) => [
  for (final step in steps) ..._resolve(step),
];

Iterable<String> _resolve(Step step) sync* {
  final table = step.table;
  if (table == null) {
    yield step.text;
  } else if (step.isDataTable) {
    yield '${step.text} {const bdd.DataTable($table)}';
  } else {
    final names = table.first;
    for (final row in table.skip(1)) {
      yield replacePlaceholders(step.text, Map.fromIterables(names, row));
    }
  }
}
