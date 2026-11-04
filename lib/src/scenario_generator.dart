import 'package:bdd_widget_test/src/feature_model.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/common.dart';
import 'package:bdd_widget_test/src/util/constants.dart';
import 'package:bdd_widget_test/src/util/dart_block.dart';

void parseScenario(
  StringBuffer sb,
  String scenarioTitle,
  List<String> steps,
  List<String> setUps,
  bool hasTearDown,
  bool hasHooks,
  String testMethodName,
  String testerName,
  List<String> tags,
  String scenarioParams, {
  String indent = '    ',
}) {
  sb.writeln(
    "$indent$testMethodName('''${escapeDartLiteral(scenarioTitle)}''', ($testerName) async {",
  );
  if (hasHooks) {
    sb.writeln('$indent  var $testSuccessVariableName = true;');
  }
  if (hasTearDown || hasHooks) {
    sb.writeln('$indent  try {');
  }
  final spaces = hasTearDown ? '$indent    ' : '$indent  ';
  if (hasHooks) {
    sb.writeln(
      "${spaces}await $setUpHookName('''${escapeDartLiteral(scenarioTitle)}''' ${tags.isNotEmpty ? ', ${tagsToString(tags)}' : ''});",
    );
  }
  for (final setUp in setUps) {
    sb.writeln('${spaces}await $setUp($testerName);');
  }

  for (final step in steps) {
    sb.writeln('${spaces}await ${getStepMethodCall(step, testerName)};');
  }

  if (hasHooks) {
    sb.writeln('$indent  } catch (_) {');
    sb.writeln('$indent    $testSuccessVariableName = false;');
    sb.writeln('$indent    rethrow;');
  }

  if (hasTearDown || hasHooks) {
    sb.writeln('$indent  } finally {');
    if (hasTearDown) {
      sb.writeln('$indent    await $tearDownMethodName($testerName);');
    }
    if (hasHooks) {
      sb.writeln('$indent    await $tearDownHookName(');
      sb.writeln("$indent      '''${escapeDartLiteral(scenarioTitle)}''',");
      sb.writeln('$indent      $testSuccessVariableName,');
      if (tags.isNotEmpty) {
        sb.writeln('$indent      ${tagsToString(tags)},');
      }
      sb.writeln('$indent    );');
    }
    sb.writeln('$indent  }');
  }

  sb.writeln(
    '$indent}${tags.isNotEmpty ? ", tags: ${tagsToString(tags)}" : ''}${scenarioParams.isNotEmpty ? ',' : ');'}',
  );
  if (scenarioParams.isNotEmpty) {
    for (final param in scenarioParams.split(', ')) {
      sb.writeln('$indent $param,');
    }
    sb.writeln(
      '$indent );',
    );
  }
}

String tagsToString(List<String> tags) {
  return "['${tags.map(escapeDartSingleQuoted).join("', '")}']";
}

/// Repeats an outline once per row of its `Examples:` table, substituting the
/// row's values for the `<placeholder>`s in the title and in every step.
/// [literalParameters] is passed on to [replacePlaceholders].
List<({String title, List<Step> steps})> expandOutline(
  Scenario scenario, {
  required bool literalParameters,
}) => [
  for (final values in scenario.examples!)
    _expand(scenario, values, literalParameters: literalParameters),
];

({String title, List<Step> steps}) _expand(
  Scenario scenario,
  Map<String, String> values, {
  required bool literalParameters,
}) => (
  title: '${scenario.title} (${values.values.join(', ')})',
  steps: [
    for (final step in scenario.steps)
      Step(
        replacePlaceholders(
          step.text,
          values,
          literalParameters: literalParameters,
        ),
        table: step.table
            ?.map((row) => row.map((cell) => _inline(cell, values)).toList())
            .toList(),
        isDataTable: step.isDataTable,
      ),
  ],
);

/// Placeholders inside a data table are always raw values — the table is a
/// Dart expression, not step text.
String _inline(String cell, Map<String, String> example) {
  var result = cell;
  for (final entry in example.entries) {
    result = result.replaceAll('<${entry.key}>', entry.value);
  }
  return result;
}

// Placeholders inside {} blocks become raw values,
// Placeholders outside {} blocks become parameters (wrapped with {})
//
// With [literalParameters], a quoted string is text, so a value inside a
// string in a {} block is escaped for it: `"<v>"` and `{'<v>'}` with the
// value `Don't` both pass `'Don\'t'`.
String replacePlaceholders(
  String line,
  Map<String, String> example, {
  bool literalParameters = false,
}) {
  final result = StringBuffer();
  var i = 0;
  while (i < line.length) {
    if (line[i] == '{') {
      final block = readDartBlock(line, i);
      if (block == null) {
        // Nothing closes the block, so the rest of the line is inside it.
        result.write(_inline(line.substring(i), example));
        break;
      }
      result.write(
        literalParameters
            ? _inlineAsText(line, i, block, example)
            : _inline(line.substring(i, block.end), example),
      );
      i = block.end;
      continue;
    }
    final key = _placeholderAt(line, i, example);
    if (key == null) {
      result.write(line[i]);
      i++;
    } else {
      result.write('{${example[key]}}');
      i += key.length + 2;
    }
  }
  return result.toString();
}

/// [_inline] for the [block] opening at [open] in [line], escaping a value
/// that lands inside one of its strings for that string.
String _inlineAsText(
  String line,
  int open,
  DartBlock block,
  Map<String, String> example,
) {
  final result = StringBuffer();
  var i = open;
  while (i < block.end) {
    final key = _placeholderAt(line, i, example);
    if (key == null) {
      result.write(line[i]);
      i++;
      continue;
    }
    final value = example[key]!;
    final string = block.strings
        .where((string) => string.start <= i && i < string.end)
        .firstOrNull;
    result.write(string == null ? value : _escapeFor(value, string.quote));
    i += key.length + 2;
  }
  return result.toString();
}

/// The name of the `<placeholder>` starting at [i] in [line], if any.
String? _placeholderAt(String line, int i, Map<String, String> example) =>
    example.keys.where((key) => line.startsWith('<$key>', i)).firstOrNull;

/// [value] as the text of a string delimited by [quote].
String _escapeFor(String value, String quote) => value
    .replaceAll(r'\', r'\\')
    .replaceAll(r'$', r'\$')
    .replaceAll(quote, '\\$quote');
