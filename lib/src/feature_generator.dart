import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/data_table_parser.dart';
import 'package:bdd_widget_test/src/scenario_generator.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/constants.dart';
import 'package:collection/collection.dart';

String generateFeatureDart(
  List<BddLine> lines,
  List<StepFile> steps,
  String testMethodName,
  bool isIntegrationTest,
) {
  final sb = StringBuffer();
  sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  sb.writeln('// ignore_for_file: unused_import, directives_ordering');
  sb.writeln();
  sb.writeln('import \'package:flutter/material.dart\';');
  sb.writeln('import \'package:flutter_test/flutter_test.dart\';');
  if (isIntegrationTest) {
    sb.writeln('import \'package:integration_test/integration_test.dart\';');
  }
  sb.writeln();

  var featureTestMethodNameOverride = testMethodName;
  final tags = <String>[];

  for (final line
      in lines.takeWhile((value) => value.type != LineType.feature)) {
    if (line.type == LineType.tag) {
      final methodName = _parseTestMethodNameTag(line.rawLine);
      if (methodName.isNotEmpty) {
        featureTestMethodNameOverride = methodName;
      } else {
        tags.add(line.rawLine.substring('@'.length));
      }
    } else {
      sb.writeln(line.rawLine);
    }
  }

  if (tags.isNotEmpty) {
    sb.writeln("@Tags(['${tags.join("', '")}'])");
  }

  for (final step in steps.map((e) => e.import).toSet()) {
    sb.writeln('import \'$step\';');
  }

  sb.writeln();
  sb.writeln('void main() {');
  if (isIntegrationTest) {
    sb.writeln('  IntegrationTestWidgetsFlutterBinding.ensureInitialized();');
    sb.writeln();
  }

  final features = splitWhen<BddLine>(
      lines.skipWhile((value) => value.type != LineType.feature), // skip header
      (e) => e.type == LineType.feature);

  for (final feature in features) {
    final hasBackground = _parseBackground(sb, feature);
    final hasAfter = _parseAfter(sb, feature);

    _parseFeature(
      sb,
      feature,
      hasBackground,
      hasAfter,
      featureTestMethodNameOverride,
    );
  }
  sb.writeln('}');
  return sb.toString();
}

bool _parseBackground(StringBuffer sb, List<BddLine> lines) =>
    _parseSetup(sb, lines, LineType.background, setUpMethodName);

bool _parseAfter(StringBuffer sb, List<BddLine> lines) =>
    _parseSetup(sb, lines, LineType.after, tearDownMethodName);

bool _parseSetup(
    StringBuffer sb, List<BddLine> lines, LineType elementType, String title) {
  var offset = lines.indexWhere((element) => element.type == elementType);
  if (offset != -1) {
    sb.writeln('  Future<void> $title(WidgetTester tester) async {');
    offset++;
    while (lines[offset].type == LineType.step) {
      sb.writeln('    await ${getStepMethodCall(lines[offset].value)};');
      offset++;
    }
    sb.writeln('  }');
  }
  return offset != -1;
}

void _parseFeature(
  StringBuffer sb,
  List<BddLine> feature,
  bool hasSetUp,
  bool hasTearDown,
  String testMethodName,
) {
  sb.writeln('  group(\'\'\'${feature.first.value}\'\'\', () {');

  final scenarios = _splitScenarios(
          feature.skipWhile((value) => !_isNewScenario(value.type)).toList())
      .toList();
  for (final scenario in scenarios) {
    final scenarioTagLines =
        scenario.where((line) => line.type == LineType.tag).toList();

    final scenarioTestMethodName = _parseTestMethodName(
      scenarioTagLines,
      testMethodName,
    );

    final flattenDataTables = replaceDataTables(
            scenario.skipWhile((line) => line.type == LineType.tag).toList())
        .toList();
    final scenariosToParse = flattenDataTables.first.type == LineType.scenario
        ? [flattenDataTables]
        : generateScenariosFromScenaioOutline(flattenDataTables);

    for (final s in scenariosToParse) {
      parseScenario(
        sb,
        s.first.value,
        s.where((e) => e.type == LineType.step).toList(),
        hasSetUp,
        hasTearDown,
        scenarioTestMethodName,
        scenarioTagLines
            .where((tag) => !tag.rawLine.startsWith(testMethodNameTag))
            .map((line) => line.rawLine.substring('@'.length))
            .toList(),
      );
    }
  }
  sb.writeln('  });');
}

bool _isNewScenario(LineType type) =>
    _isScenarioKindLine(type) || type == LineType.tag;

bool _isScenarioKindLine(LineType type) =>
    type == LineType.scenario || type == LineType.scenarioOutline;

String _parseTestMethodName(
  List<BddLine> featureTagLines,
  String testMethodName,
) {
  var scenarioTestMethodName = testMethodName;

  final customMethodTagLine = featureTagLines
      .firstWhereOrNull((line) => line.rawLine.startsWith(testMethodNameTag));

  if (customMethodTagLine != null) {
    final testMethodNameOverride = _parseTestMethodNameTag(
      customMethodTagLine.rawLine,
    );
    if (testMethodNameOverride.isNotEmpty) {
      scenarioTestMethodName = testMethodNameOverride;
    }
  }
  return scenarioTestMethodName;
}

String _parseTestMethodNameTag(String rawLine) {
  if (rawLine.startsWith(testMethodNameTag)) {
    return rawLine.substring(testMethodNameTag.length).trim();
  }
  return '';
}

List<List<T>> splitWhen<T>(Iterable<T> original, bool Function(T) predicate) =>
    original.fold(<List<T>>[], (previousValue, element) {
      if (predicate(element)) {
        previousValue.add([element]);
      } else {
        previousValue.last.add(element);
      }
      return previousValue;
    });

Iterable<List<BddLine>> _splitScenarios(List<BddLine> lines) sync* {
  for (var current = 0; current < lines.length;) {
    if (_isScenarioKindLine(lines[current].type) ||
        lines[current].type == LineType.tag) {
      final scenario = _parseScenario(lines.sublist(current)).toList();
      current += scenario.length;
      yield scenario;
    }
  }
}

Iterable<BddLine> _parseScenario(List<BddLine> lines) sync* {
  var isNewScenario = true;
  for (final line in lines) {
    if (line.type == LineType.step) {
      isNewScenario = false;
    }
    if (!isNewScenario && _isNewScenario(line.type)) {
      return;
    }
    yield line;
  }
}
