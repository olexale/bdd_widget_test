import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/step/bdd_step.dart';
import 'package:bdd_widget_test/src/step/generic_step.dart';
import 'package:bdd_widget_test/src/step/i_dismiss_the_page.dart';
import 'package:bdd_widget_test/src/step/i_dont_see_icon.dart';
import 'package:bdd_widget_test/src/step/i_dont_see_text.dart';
import 'package:bdd_widget_test/src/step/i_see_icon.dart';
import 'package:bdd_widget_test/src/step/i_see_text.dart';
import 'package:bdd_widget_test/src/step/i_tap_icon.dart';
import 'package:bdd_widget_test/src/step/i_tap_text.dart';
import 'package:bdd_widget_test/src/step/i_wait.dart';
import 'package:bdd_widget_test/src/step/the_app_is_running_step.dart';
import 'package:bdd_widget_test/src/util/string_utils.dart';

String getStepFilename(String stepText) {
  final step = getStepMethodName(stepText);
  return underscore(step);
}

String getStepMethodName(String stepText) {
  final text = stepText
      .replaceAll(parametersRegExp, '')
      .replaceAll(charactersAndNumbersRegExp, '')
      .replaceAll(repeatingSpacesRegExp, ' ')
      .trim()
      .replaceAll(' ', '_');
  return camelize(text);
}

String getStepMethodCall(String stepLine) {
  final name = getStepMethodName(stepLine);

  final params = parametersValueRegExp.allMatches(stepLine);
  if (params.isEmpty) {
    return '$name(tester)';
  }

  final methodParameters = params.map((p) => p.group(0)).join(', ');
  return '$name(tester, $methodParameters)';
}

String generateStepDart(String package, String line) {
  final methodName = getStepMethodName(line);
  final bddStep = _getStep(methodName, package, line);
  return bddStep.content;
}

BddStep _getStep(String methodName, String package, String line) {
  final factory =
      predefinedSteps[methodName] ?? (_, __) => GenericStep(methodName, line);
  return factory(package, line);
}

final predefinedSteps = <String, BddStep Function(String, String)>{
  'theAppIsRunning': (package, _) => TheAppInRunningStep(package),
  'iSeeText': (_, __) => ISeeText(),
  'iSeeIcon': (_, __) => ISeeIcon(),
  'iTapText': (_, __) => ITapText(),
  'iTapIcon': (_, __) => ITapIcon(),
  'iDontSeeIcon': (_, __) => IDontSeeIcon(),
  'iDontSeeText': (_, __) => IDontSeeText(),
  'iDismissThePage': (_, __) => IDismissThePage(),
  'iWait': (_, __) => IWait(),
};
