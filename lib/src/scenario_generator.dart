import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/constants.dart';

void parseScenario(
  StringBuffer sb,
  String scenarioTitle,
  List<BddLine> scenario,
  bool hasSetUp,
  bool hasTearDown,
  String testMethodName,
  List<String> tags,
) {
  sb.writeln(
    "    $testMethodName('''$scenarioTitle''', (tester) async {",
  );
  if (hasTearDown) {
    sb.writeln('      try {');
  }
  final spaces = hasTearDown ? '        ' : '      ';
  if (hasSetUp) {
    sb.writeln('${spaces}await $setUpMethodName(tester);');
  }

  for (final step in scenario) {
    sb.writeln('${spaces}await ${getStepMethodCall(step.value)};');
  }

  if (hasTearDown) {
    sb.writeln('      } finally {');
    sb.writeln('        await $tearDownMethodName(tester);');
    sb.writeln('      }');
  }
  sb.writeln(
    '    }${tags.isNotEmpty ? ", tags: ['${tags.join("', '")}']" : ''});',
  );
}

List<List<BddLine>> generateScenariosFromScenaioOutline(
  List<BddLine> scenario,
) {
  final examples = _getExamples(scenario);
  return examples
      .map((e) => _processScenarioLines(scenario, e).toList())
      .toList();
}

List<Map<String, String>> _getExamples(
  List<BddLine> scenario,
) {
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
