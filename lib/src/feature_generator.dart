import 'dart:math';

import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/step_generator.dart';

String generateFeatureDart(List<BddLine> lines, List<StepFile> steps) {
  final sb = StringBuffer();
  sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  sb.writeln('// ignore_for_file: unused_import, directives_ordering');
  sb.writeln('');
  sb.writeln('import \'package:flutter/material.dart\';');
  sb.writeln('import \'package:flutter_test/flutter_test.dart\';');
  sb.writeln('');

  for (final line
      in lines.takeWhile((value) => value.type != LineType.feature)) {
    sb.writeln(line.rawLine);
  }

  for (final step in steps.map((e) => e.import).toSet()) {
    sb.writeln('import \'$step\';');
  }

  sb.writeln('');
  sb.writeln('void main() {');

  final features = splitWhen<BddLine>(
      lines.skipWhile((value) => value.type != LineType.feature), // skip header
      (e) => e.type == LineType.feature);

  for (final feature in features) {
    final backgroundOffset = _parseBackground(sb, feature);
    final afterOffset = _parseAfter(sb, feature);
    final offset = _calculateOffset(backgroundOffset, afterOffset);
    _parseFeature(sb, feature, offset);
  }
  sb.writeln('}');
  return sb.toString();
}

int _parseBackground(StringBuffer sb, List<BddLine> lines) =>
    _parseSetup(sb, lines, LineType.background, 'setUp');

int _parseAfter(StringBuffer sb, List<BddLine> lines) =>
    _parseSetup(sb, lines, LineType.after, 'tearDown');

int _calculateOffset(int backgroundOffset, int afterOffset) {
  if (backgroundOffset == -1 && afterOffset == -1) {
    return -1;
  }
  return max(backgroundOffset, afterOffset);
}

int _parseSetup(
    StringBuffer sb, List<BddLine> lines, LineType elementType, String title) {
  var offset = lines.indexWhere((element) => element.type == elementType);
  if (offset != -1) {
    sb.writeln('  $title(() async {');
    offset++;
    while (lines[offset].type == LineType.step) {
      sb.writeln('    await ${getStepMethodName(lines[offset].value)}();');
      offset++;
    }
    sb.writeln('  });');
  }
  return offset;
}

void _parseFeature(StringBuffer sb, List<BddLine> feature, int offset) {
  sb.writeln('  group(\'${feature.first.value}\', () {');

  final scenarios = splitWhen<BddLine>(
      feature.skip(offset == -1
          ? 1 // Skip 'Feature:'
          : offset), // or 'Backround:' / 'After:'
      (e) => e.type == LineType.scenario).toList();
  for (final scenario in scenarios) {
    _parseScenario(sb, scenario);
  }
  sb.writeln('  });');
}

void _parseScenario(StringBuffer sb, List<BddLine> scenario) {
  sb.writeln('    testWidgets(\'${scenario.first.value}\', (tester) async {');

  for (final step in scenario.skip(1)) {
    sb.writeln('      await ${getStepMethodCall(step.value)};');
  }

  sb.writeln('    });');
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
