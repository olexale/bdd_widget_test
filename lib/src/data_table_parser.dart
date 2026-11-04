import 'package:bdd_widget_test/src/feature_model.dart';
import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/scenario_generator.dart';
import 'package:bdd_widget_test/src/util/common.dart';

/// Whether the table attached to a step is meant as Examples (repeating the
/// step once per row) rather than as a cucumber data table argument.
///
/// Heuristic: if the step contains placeholders like `<name>` and the header
/// row names ALL of them, treat the table as Examples; otherwise treat it as a
/// cucumber data table.
///
/// With [literalParameters], a header may be named as [replacePlaceholders]
/// finds it in a string: escaped for that string. `"<user's name>"` and
/// `"<C:\\dir>"` are rewritten to `'<user\'s name>'` and `'<C:\\dir>'`, which
/// the headers `user's name` and `C:\dir` name.
bool isExamplesTable(
  String stepText,
  List<List<String>> table, {
  required bool literalParameters,
}) {
  final placeholders = examplesRegExp
      .allMatches(stepText)
      .map((match) => match.group(1)!.trim())
      .where((placeholder) => placeholder.isNotEmpty)
      .toSet();
  if (placeholders.isEmpty) {
    return false;
  }
  final headers = {
    for (final header in table.firstOrNull ?? const <String>[]) ...[
      header,
      if (literalParameters) ...[
        escapeDartString(header, "'"),
        escapeDartString(header, '"'),
      ],
    ],
  };
  if (headers.isEmpty) {
    return false;
  }
  return placeholders.every(headers.contains);
}

/// Resolves every step into the text of the call to generate for it, folding
/// in whatever table was written underneath. [literalParameters] is passed
/// on to [replacePlaceholders].
List<String> resolveSteps(
  Iterable<Step> steps, {
  required bool literalParameters,
}) => [
  for (final step in steps)
    ..._resolve(step, literalParameters: literalParameters),
];

Iterable<String> _resolve(
  Step step, {
  required bool literalParameters,
}) sync* {
  final table = step.table;
  if (table == null) {
    yield step.text;
  } else if (step.isDataTable) {
    yield '${step.text} {const bdd.DataTable($table)}';
  } else {
    final names = table.first;
    for (final row in table.skip(1)) {
      yield replacePlaceholders(
        step.text,
        Map.fromIterables(names, row),
        literalParameters: literalParameters,
      );
    }
  }
}
