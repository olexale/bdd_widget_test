import 'package:bdd_widget_test/src/feature_model.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/constants.dart';

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
    "$indent$testMethodName('''$scenarioTitle''', ($testerName) async {",
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
      "${spaces}await $setUpHookName('''$scenarioTitle''' ${tags.isNotEmpty ? ', ${tagsToString(tags)}' : ''});",
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
      sb.writeln("$indent      '''$scenarioTitle''',");
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
  return "['${tags.join("', '")}']";
}

/// Repeats an outline once per row of its `Examples:` table, substituting the
/// row's values for the `<placeholder>`s in the title and in every step.
List<({String title, List<Step> steps})> expandOutline(Scenario scenario) => [
  for (final values in scenario.examples!) _expand(scenario, values),
];

({String title, List<Step> steps}) _expand(
  Scenario scenario,
  Map<String, String> values,
) => (
  title: '${scenario.title} (${values.values.join(', ')})',
  steps: [
    for (final step in scenario.steps)
      Step(
        replacePlaceholders(step.text, values),
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
String replacePlaceholders(
  String line,
  Map<String, String> example,
) {
  final result = StringBuffer();
  var i = 0;
  var braceDepth = 0;

  while (i < line.length) {
    // Track brace depth to know if we're inside a parameter block
    if (line[i] == '{') {
      braceDepth++;
      result.write('{');
      i++;
    } else if (line[i] == '}') {
      braceDepth--;
      result.write('}');
      i++;
    } else if (line[i] == '<') {
      // Check if this is a placeholder
      var foundPlaceholder = false;
      for (final key in example.keys) {
        final placeholder = '<$key>';
        if (i + placeholder.length <= line.length &&
            line.substring(i, i + placeholder.length) == placeholder) {
          // Found a placeholder
          if (braceDepth > 0) {
            // Inside a parameter block - use raw value
            result.write(example[key]);
          } else {
            // Outside parameter blocks - wrap with {}
            result.write('{${example[key]}}');
          }
          i += placeholder.length;
          foundPlaceholder = true;
          break;
        }
      }
      if (!foundPlaceholder) {
        result.write(line[i]);
        i++;
      }
    } else {
      result.write(line[i]);
      i++;
    }
  }

  return result.toString();
}
