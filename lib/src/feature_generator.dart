import 'package:bdd_widget_test/src/bdd_line.dart';
import 'package:bdd_widget_test/src/data_table_parser.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/hook_file.dart';
import 'package:bdd_widget_test/src/scenario_generator.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/common.dart';
import 'package:bdd_widget_test/src/util/constants.dart';

String generateFeatureDart(
  List<BddLine> lines,
  List<StepFile> steps,
  String testMethodName,
  String testerType,
  String testerName,
  bool includeIntegrationTestBinding,
  bool includeIntegrationTestImport,
  HookFile? hookFile,
  GeneratorOptions generatorOptions,
) {
  final sb = StringBuffer();
  sb.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  sb.writeln('// ignore_for_file: type=lint, type=warning');

  sb.writeln();
  var featureTestMethodNameOverride = testMethodName;
  var testerTypeOverride = testerType;
  var testerNameOverride = testerName;

  final linesBeforeFeature =
      lines.takeWhile((value) => value.type != LineType.feature).toList();

  final tagLines = linesBeforeFeature.where(
    (line) => line.type == LineType.tag,
  );
  final tags = <String>[];
  for (final line in tagLines) {
    final methodName = parseCustomTag(line.rawLine, testMethodNameTag);
    final parsedTesterType = parseCustomTag(line.rawLine, testerTypeTag);
    final parsedTesterName = parseCustomTag(line.rawLine, testerNameTag);

    if (methodName.isNotEmpty ||
        parsedTesterType.isNotEmpty ||
        parsedTesterName.isNotEmpty) {
      if (methodName.isNotEmpty) featureTestMethodNameOverride = methodName;
      if (parsedTesterType.isNotEmpty) testerTypeOverride = parsedTesterType;
      if (parsedTesterName.isNotEmpty) testerNameOverride = parsedTesterName;
    } else {
      tags.add(line.rawLine.substring('@'.length));
    }
  }
  if (tags.isNotEmpty) {
    sb.writeln("@Tags(['${tags.join("', '")}'])");
  }

  for (final line in linesBeforeFeature.where(
    (line) => line.type != LineType.tag,
  )) {
    sb.writeln(line.rawLine);
  }

  if (hasBddDataTable(lines)) {
    sb.writeln("import 'package:bdd_widget_test/data_table.dart' as bdd;");
  }

  // Use custom headers if provided, otherwise use default imports
  if (generatorOptions.customHeaders.isNotEmpty) {
    generatorOptions.customHeaders.forEach(sb.writeln);
  } else {
    sb.writeln("import 'package:flutter/material.dart';");
    sb.writeln("import 'package:flutter_test/flutter_test.dart';");
  }

  if (includeIntegrationTestImport) {
    sb.writeln("import 'package:integration_test/integration_test.dart';");
  }

  sb.writeln();
  if (hookFile != null) {
    sb.writeln("import '${hookFile.import}';");
  }

  for (final step in steps.map((e) => e.import).toSet()) {
    sb.writeln("import '$step';");
  }

  sb.writeln();
  sb.writeln('void main() {');
  if (includeIntegrationTestBinding) {
    sb.writeln('  IntegrationTestWidgetsFlutterBinding.ensureInitialized();');
    sb.writeln();
  }

  if (hookFile != null) {
    _parseSetupAllHook(
      sb,
      hookClass,
      setUpAllHookName,
      setUpAllCallbackName,
    );
    _parseSetupAllHook(
      sb,
      hookClass,
      tearDownAllHookName,
      tearDownAllCallbackName,
    );
    sb.writeln();
  }

  final features = splitWhen<BddLine>(
    lines.skipWhile((value) => value.type != LineType.feature), // skip header
    (e) => e.type == LineType.feature,
  );

  for (final feature in features) {
    sb.writeln("  group('''${feature.first.value}''', () {");

    final hasBackground = _parseBackground(
      sb,
      feature,
      testerTypeOverride,
      testerNameOverride,
    );
    final hasAfter = _parseAfter(
      sb,
      feature,
      testerTypeOverride,
      testerNameOverride,
    );

    if (hookFile != null) {
      _parseBeforeHook(
        sb,
        hookClass,
        testerTypeOverride,
        testerNameOverride,
      );
      _parseAfterHook(
        sb,
        hookClass,
        testerTypeOverride,
        testerNameOverride,
      );
    }

    _parseFeature(
      sb,
      feature,
      hasBackground,
      hasAfter,
      hookFile != null,
      featureTestMethodNameOverride,
      testerNameOverride,
    );
  }
  sb.writeln('}');
  return sb.toString();
}

void _parseAfterHook(
  StringBuffer sb,
  String hookClass,
  String testerType,
  String testerName,
) {
  sb.writeln(
    '    Future<void> $tearDownHookName(String title, bool $testSuccessVariableName, [List<String>? tags]) async {',
  );
  sb.writeln(
    '      await $hookClass.$tearDownHookName(title, $testSuccessVariableName, tags);',
  );
  sb.writeln('    }');
}

void _parseBeforeHook(
  StringBuffer sb,
  String hookClass,
  String testerType,
  String testerName,
) {
  sb.writeln(
    '    Future<void> $setUpHookName(String title, [List<String>? tags]) async {',
  );
  sb.writeln(
    '      await $hookClass.$setUpHookName(title, tags);',
  );
  sb.writeln('    }');
}

void _parseSetupAllHook(
  StringBuffer sb,
  String hookClass,
  String hookClassMethod,
  String callbackName,
) {
  sb.writeln(
    '  $callbackName(() async {',
  );
  sb.writeln(
    '    await $hookClass.$hookClassMethod();',
  );
  sb.writeln('  });');
}

bool _parseBackground(
  StringBuffer sb,
  List<BddLine> lines,
  String testerType,
  String testerName,
) => _parseSetup(
  sb,
  lines,
  LineType.background,
  setUpMethodName,
  testerType,
  testerName,
);

bool _parseAfter(
  StringBuffer sb,
  List<BddLine> lines,
  String testerType,
  String testerName,
) => _parseSetup(
  sb,
  lines,
  LineType.after,
  tearDownMethodName,
  testerType,
  testerName,
);

bool _parseSetup(
  StringBuffer sb,
  List<BddLine> lines,
  LineType elementType,
  String title,
  String testerType,
  String testerName,
) {
  final flattenDataTables =
      replaceDataTables(
        lines.skipWhile((line) => line.type == LineType.tag).toList(),
      ).toList();
  var offset = flattenDataTables.indexWhere(
    (element) => element.type == elementType,
  );
  if (offset != -1) {
    sb.writeln('    Future<void> $title($testerType $testerName) async {');
    offset++;
    while (flattenDataTables[offset].type == LineType.step ||
        flattenDataTables[offset].type == LineType.dataTableStep) {
      sb.writeln(
        '      await ${getStepMethodCall(flattenDataTables[offset].value, testerName)};',
      );
      offset++;
    }
    sb.writeln('    }');
  }
  return offset != -1;
}

void _parseFeature(
  StringBuffer sb,
  List<BddLine> feature,
  bool hasSetUp,
  bool hasTearDown,
  bool hasHooks,
  String testMethodName,
  String testerName,
) {
  final scenarios =
      _splitScenarios(
        feature.skipWhile((value) => !_isNewScenario(value.type)).toList(),
      ).toList();
  for (final scenario in scenarios) {
    final scenarioTagLines =
        scenario.where((line) => line.type == LineType.tag).toList();
    final scenarioTestMethodName = parseCustomTagFromFeatureTagLine(
      scenarioTagLines,
      testMethodName,
      testMethodNameTag,
    );

    final scenarioParams = parseCustomTagFromFeatureTagLine(
      scenarioTagLines,
      '',
      scenarioParamsTag,
    );

    final flattenDataTables =
        replaceDataTables(
          scenario.skipWhile((line) => line.type == LineType.tag).toList(),
        ).toList();
    final scenariosToParse =
        flattenDataTables.first.type == LineType.scenario
            ? [flattenDataTables]
            : generateScenariosFromScenarioOutline(flattenDataTables);

    for (final s in scenariosToParse) {
      parseScenario(
        sb,
        s.first.value,
        s
            .where(
              (e) =>
                  e.type == LineType.step || e.type == LineType.dataTableStep,
            )
            .toList(),
        hasSetUp,
        hasTearDown,
        hasHooks,
        scenarioTestMethodName,
        testerName,
        scenarioTagLines
            .where(
              (tag) =>
                  !tag.rawLine.startsWith(testMethodNameTag) &&
                  !tag.rawLine.startsWith(scenarioParamsTag),
            )
            .map((line) => line.rawLine.substring('@'.length))
            .toList(),
        scenarioParams,
      );
    }
  }
  sb.writeln('  });');
}

bool _isNewScenario(LineType type) =>
    _isScenarioKindLine(type) || type == LineType.tag;

bool _isScenarioKindLine(LineType type) =>
    type == LineType.scenario || type == LineType.scenarioOutline;

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
    if (line.type == LineType.step || line.type == LineType.dataTableStep) {
      isNewScenario = false;
    }
    if (!isNewScenario && _isNewScenario(line.type)) {
      return;
    }
    yield line;
  }
}
