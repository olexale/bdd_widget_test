import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/step_generator.dart';

const _setUpMethodName = 'bddSetUp';
const _tearDownMethodName = 'bddTearDown';

String generateFeatureDart(
    List<BddLine> lines, List<StepFile> steps, String testMethodName) {
  final sb = StringBuffer();
  sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  sb.writeln('// ignore_for_file: unused_import, directives_ordering');
  sb.writeln();
  sb.writeln('import \'package:flutter/material.dart\';');
  sb.writeln('import \'package:flutter_test/flutter_test.dart\';');
  sb.writeln();

  var featureTestMethodNameOverride = testMethodName;

  for (final line
      in lines.takeWhile((value) => value.type != LineType.feature)) {
    if (line.type == LineType.tag) {
      final methodName = _parseTestMethodNameTag(line.rawLine);
      if (methodName.isNotEmpty) {
        featureTestMethodNameOverride = methodName;
      }
    } else {
      sb.writeln(line.rawLine);
    }
  }

  for (final step in steps.map((e) => e.import).toSet()) {
    sb.writeln('import \'$step\';');
  }

  sb.writeln();
  sb.writeln('void main() {');

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
    _parseSetup(sb, lines, LineType.background, _setUpMethodName);

bool _parseAfter(StringBuffer sb, List<BddLine> lines) =>
    _parseSetup(sb, lines, LineType.after, _tearDownMethodName);

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
  sb.writeln('  group(\'${feature.first.value}\', () {');

  final scenarios = splitWhen<BddLine>(
      feature.skipWhile((e) => e.type != LineType.scenario),
      (e) => e.type == LineType.scenario).toList();
  for (final scenario in scenarios) {
    final scenarioTestMethodName =
        _parseScenaioTags(feature, scenario.first, testMethodName);
    _parseScenario(
      sb,
      scenario.first.value,
      scenario.where((e) => e.type == LineType.step).toList(),
      hasSetUp,
      hasTearDown,
      scenarioTestMethodName,
    );
  }
  sb.writeln('  });');
}

String _parseScenaioTags(
  List<BddLine> feature,
  BddLine scenario,
  String testMethodName,
) {
  var scenarioTestMethodName = testMethodName;
  final prevLine = feature[feature.indexOf(scenario) - 1];
  if (prevLine.type == LineType.tag) {
    final testMethodNameOverride = _parseTestMethodNameTag(prevLine.rawLine);
    if (testMethodNameOverride.isNotEmpty) {
      scenarioTestMethodName = testMethodNameOverride;
    }
  }
  return scenarioTestMethodName;
}

void _parseScenario(
  StringBuffer sb,
  String scenarioTitle,
  List<BddLine> scenario,
  bool hasSetUp,
  bool hasTearDown,
  String testMethodName,
) {
  sb.writeln('    $testMethodName(\'$scenarioTitle\', (tester) async {');
  if (hasSetUp) {
    sb.writeln('      await $_setUpMethodName(tester);');
  }

  for (final step in scenario) {
    sb.writeln('      await ${getStepMethodCall(step.value)};');
  }

  if (hasTearDown) {
    sb.writeln('      await $_tearDownMethodName(tester);');
  }

  sb.writeln('    });');
}

String _parseTestMethodNameTag(String rawLine) {
  const tag = '@testMethodName:';
  if (rawLine.startsWith(tag)) {
    return rawLine.substring(tag.length).trim();
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
