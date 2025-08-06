import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/constants.dart';

void parseScenario(
  StringBuffer sb,
  String scenarioTitle,
  List<BddLine> scenario,
  bool hasSetUp,
  bool hasTearDown,
  bool hasHooks,
  String testMethodName,
  String testerName,
  List<String> tags,
  String scenarioParams,
) {
  sb.writeln("    $testMethodName('''$scenarioTitle''', ($testerName) async {");
  if (hasHooks) {
    sb.writeln('      var $testSuccessVariableName = true;');
  }
  if (hasTearDown || hasHooks) {
    sb.writeln('      try {');
  }
  final spaces = hasTearDown ? '        ' : '      ';
  if (hasHooks) {
    sb.writeln(
      "${spaces}await $setUpHookName('''$scenarioTitle''' ${tags.isNotEmpty ? ', ${tagsToString(tags)}' : ''});",
    );
  }
  if (hasSetUp) {
    sb.writeln('${spaces}await $setUpMethodName($testerName);');
  }

  for (final step in scenario) {
    sb.writeln('${spaces}await ${getStepMethodCall(step.value, testerName)};');
  }

  if (hasHooks) {
    sb.writeln('      } catch (_) {');
    sb.writeln('        $testSuccessVariableName = false;');
    sb.writeln('        rethrow;');
  }

  if (hasTearDown | hasHooks) {
    sb.writeln('      } finally {');
    if (hasTearDown) {
      sb.writeln('        await $tearDownMethodName($testerName);');
    }
    if (hasHooks) {
      sb.writeln('        await $tearDownHookName(');
      sb.writeln("          '''$scenarioTitle''',");
      sb.writeln('          $testSuccessVariableName,');
      if (tags.isNotEmpty) {
        sb.writeln('          ${tagsToString(tags)},');
      }
      sb.writeln('        );');
    }
    sb.writeln('      }');
  }

  sb.writeln(
    '    }${tags.isNotEmpty ? ", tags: ${tagsToString(tags)}" : ''}${scenarioParams.isNotEmpty ? ',' : ');'}',
  );
  if (scenarioParams.isNotEmpty) {
    for (final param in scenarioParams.split(', ')) {
      sb.writeln('     $param,');
    }
    sb.writeln('     );');
  }
}

String tagsToString(List<String> tags) {
  return "['${tags.join("', '")}']";
}

List<List<BddLine>> generateScenariosFromScenarioOutline(
  List<BddLine> scenario,
) {
  final examples = _getExamples(scenario);
  return examples
      .map((e) => _processScenarioLines(scenario, e).toList())
      .toList();
}

List<Map<String, String>> _getExamples(List<BddLine> scenario) {
  final exampleLines = scenario
      .skipWhile((l) => l.type != LineType.exampleTitle)
      .where((l) => l.type == LineType.examples)
      .map(
        (e) => e.rawLine.substring(
          // Remove the first and the last '|' separator
          1,
          e.rawLine.length - 1,
        ),
      )
      .map(_parseExampleLine);
  final names = exampleLines.first;
  return exampleLines.skip(1).map((e) => Map.fromIterables(names, e)).toList();
}

List<String> _parseExampleLine(String line) =>
    line.split('|').map((e) => e.trim()).toList();

Iterable<BddLine> _processScenarioLines(
  List<BddLine> lines,
  Map<String, String> examples,
) sync* {
  final name = lines.first;
  yield BddLine.fromValue(
    name.type,
    '${name.value} (${examples.values.join(', ')})',
  );

  for (final line in lines.skip(1)) {
    yield BddLine.fromValue(
      line.type,
      _replacePlaceholders(line.value, examples),
    );
  }
}

String _replacePlaceholders(String line, Map<String, String> example) {
  var replaced = line;
  for (final e in example.keys) {
    replaced = replaced.replaceAll('<$e>', '{${example[e]}}');
  }
  return replaced;
}
