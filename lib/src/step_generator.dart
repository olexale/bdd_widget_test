import 'package:bdd_widget_test/src/step/bdd_step.dart';
import 'package:bdd_widget_test/src/step/generic_step.dart';
import 'package:bdd_widget_test/src/step/i_dont_see_icon.dart';
import 'package:bdd_widget_test/src/step/i_dont_see_text.dart';
import 'package:bdd_widget_test/src/step/i_see_icon.dart';
import 'package:bdd_widget_test/src/step/i_see_text.dart';
import 'package:bdd_widget_test/src/step/i_tap_icon.dart';
import 'package:bdd_widget_test/src/step/i_tap_text.dart';
import 'package:bdd_widget_test/src/step/the_app_is_running_step.dart';
import 'package:strings/strings.dart';

final parametersRegExp = RegExp(r'\{\S+\}', caseSensitive: false);
final charactersAndNumbersRegExp = RegExp(r'[^\w\s\d]+');
final repeatingSpacesRegExp = RegExp(r'\s+');

String getStepFilename(String stepText) {
  final step = getStepMethodName(stepText);
  var u = underscore(step);
  return u;
}

String getStepMethodName(String stepText) {
  final text = stepText
      .replaceAll(parametersRegExp, '')
      .replaceAll(charactersAndNumbersRegExp, '')
      .replaceAll(repeatingSpacesRegExp, ' ')
      .trim()
      .replaceAll(' ', '_');
  var c = camelize(text);
  return c;
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
  'TheAppIsRunning': (package, _) => TheAppInRunningStep(package),
  'ISeeText': (_, __) => ISeeText(),
  'ISeeIcon': (_, __) => ISeeIcon(),
  'ITapText': (_, __) => ITapText(),
  'ITapIcon': (_, __) => ITapIcon(),
  'IDontSeeIcon': (_, __) => IDontSeeIcon(),
  'IDontSeeText': (_, __) => IDontSeeText(),
};
