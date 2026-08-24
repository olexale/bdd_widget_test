import 'package:bdd_widget_test/src/data_table_parser.dart';
import 'package:bdd_widget_test/src/feature_model.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/hook_file.dart';
import 'package:bdd_widget_test/src/scenario_generator.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/common.dart';
import 'package:bdd_widget_test/src/util/constants.dart';

String generateFeatureDart(
  FeatureFileModel model,
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

  final tags = <String>[];
  for (final line in model.tagLines) {
    final methodName = parseCustomTag(line, testMethodNameTag);
    final parsedTesterType = parseCustomTag(line, testerTypeTag);
    final parsedTesterName = parseCustomTag(line, testerNameTag);

    if (methodName.isNotEmpty ||
        parsedTesterType.isNotEmpty ||
        parsedTesterName.isNotEmpty) {
      if (methodName.isNotEmpty) featureTestMethodNameOverride = methodName;
      if (parsedTesterType.isNotEmpty) testerTypeOverride = parsedTesterType;
      if (parsedTesterName.isNotEmpty) testerNameOverride = parsedTesterName;
    } else {
      tags.add(line.substring('@'.length));
    }
  }
  if (tags.isNotEmpty) {
    sb.writeln("@Tags(['${tags.join("', '")}'])");
  }

  model.header.forEach(sb.writeln);

  if (model.hasDataTable) {
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

  for (final feature in model.features) {
    sb.writeln("  group('''${feature.title}''', () {");

    final hasBackground = _writeSetup(
      sb,
      feature.background,
      setUpMethodName,
      testerTypeOverride,
      testerNameOverride,
    );
    final hasAfter = _writeSetup(
      sb,
      feature.after,
      tearDownMethodName,
      testerTypeOverride,
      testerNameOverride,
    );
    final featureSetUps = [if (hasBackground) setUpMethodName];

    if (hookFile != null) {
      _parseBeforeHook(sb, hookClass);
      _parseAfterHook(sb, hookClass);
    }

    for (final scenario in feature.scenarios) {
      _writeScenario(
        sb,
        scenario,
        featureSetUps,
        hasAfter,
        hookFile != null,
        featureTestMethodNameOverride,
        testerNameOverride,
      );
    }

    for (final rule in feature.rules) {
      sb.writeln("    group('''${rule.title}''', () {");
      final hasRuleBackground = _writeSetup(
        sb,
        rule.background,
        ruleSetUpMethodName,
        testerTypeOverride,
        testerNameOverride,
        indent: '      ',
      );
      for (final scenario in rule.scenarios) {
        _writeScenario(
          sb,
          scenario,
          [...featureSetUps, if (hasRuleBackground) ruleSetUpMethodName],
          hasAfter,
          hookFile != null,
          featureTestMethodNameOverride,
          testerNameOverride,
          indent: '      ',
        );
      }
      sb.writeln('    });');
    }
    sb.writeln('  });');
  }
  sb.writeln('}');
  return sb.toString();
}

void _parseAfterHook(StringBuffer sb, String hookClass) {
  sb.writeln(
    '    Future<void> $tearDownHookName(String title, bool $testSuccessVariableName, [List<String>? tags]) async {',
  );
  sb.writeln(
    '      await $hookClass.$tearDownHookName(title, $testSuccessVariableName, tags);',
  );
  sb.writeln('    }');
}

void _parseBeforeHook(StringBuffer sb, String hookClass) {
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

/// Writes a `Background:` or `After:` section as a function the scenarios
/// call, and reports whether there was one to write.
bool _writeSetup(
  StringBuffer sb,
  List<Step> steps,
  String title,
  String testerType,
  String testerName, {
  String indent = '    ',
}) {
  if (steps.isEmpty) {
    return false;
  }
  sb.writeln('${indent}Future<void> $title($testerType $testerName) async {');
  for (final step in resolveSteps(steps)) {
    sb.writeln('$indent  await ${getStepMethodCall(step, testerName)};');
  }
  sb.writeln('$indent}');
  return true;
}

void _writeScenario(
  StringBuffer sb,
  Scenario scenario,
  List<String> setUps,
  bool hasTearDown,
  bool hasHooks,
  String testMethodName,
  String testerName, {
  String indent = '    ',
}) {
  final scenarioTestMethodName = parseCustomTagValue(
    scenario.tagLines,
    testMethodName,
    testMethodNameTag,
  );

  final scenarioParams = parseCustomTagValue(
    scenario.tagLines,
    '',
    scenarioParamsTag,
  );

  final tags = scenario.tagLines
      .where(
        (tag) =>
            !tag.startsWith(testMethodNameTag) &&
            !tag.startsWith(scenarioParamsTag),
      )
      .map((tag) => tag.substring('@'.length))
      .toList();

  final runs = scenario.isOutline
      ? expandOutline(scenario)
      : [(title: scenario.title, steps: scenario.steps)];

  for (final run in runs) {
    parseScenario(
      sb,
      run.title,
      resolveSteps(run.steps),
      setUps,
      hasTearDown,
      hasHooks,
      scenarioTestMethodName,
      testerName,
      tags,
      scenarioParams,
      indent: indent,
    );
  }
}
