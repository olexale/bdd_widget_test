import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/step/bdd_step.dart';
import 'package:bdd_widget_test/src/step/generic_step.dart';
import 'package:bdd_widget_test/src/step/i_dismiss_the_page.dart';
import 'package:bdd_widget_test/src/step/i_dont_see_icon.dart';
import 'package:bdd_widget_test/src/step/i_dont_see_rich_text.dart';
import 'package:bdd_widget_test/src/step/i_dont_see_text.dart';
import 'package:bdd_widget_test/src/step/i_dont_see_widget.dart';
import 'package:bdd_widget_test/src/step/i_enter_into_input_field.dart';
import 'package:bdd_widget_test/src/step/i_see_disabled_elevated_button.dart';
import 'package:bdd_widget_test/src/step/i_see_enabled_elevated_button.dart';
import 'package:bdd_widget_test/src/step/i_see_exactly_widgets.dart';
import 'package:bdd_widget_test/src/step/i_see_icon.dart';
import 'package:bdd_widget_test/src/step/i_see_multiple_texts.dart';
import 'package:bdd_widget_test/src/step/i_see_multiple_widgets.dart';
import 'package:bdd_widget_test/src/step/i_see_rich_text.dart';
import 'package:bdd_widget_test/src/step/i_see_text.dart';
import 'package:bdd_widget_test/src/step/i_see_widget.dart';
import 'package:bdd_widget_test/src/step/i_tap_icon.dart';
import 'package:bdd_widget_test/src/step/i_tap_text.dart';
import 'package:bdd_widget_test/src/step/i_wait.dart';
import 'package:bdd_widget_test/src/step/the_app_is_running_step.dart';
import 'package:bdd_widget_test/src/util/string_utils.dart';
import 'package:diacritic/diacritic.dart';

String getStepFilename(String stepText) {
  final step = getStepMethodName(stepText);
  return underscore(step);
}

String getStepMethodName(String stepText) {
  final step = parseRawStepLine(stepText).first;
  return _camelizedString(step);
}

String getStepMethodCall(
  String stepLine,
  String customTesterName, {
  List<String>? forceParams,
}) {
  final step = parseRawStepLine(stepLine);
  final parameters = [
    customTesterName,
    if (forceParams != null) ...forceParams else ...step.skip(1),
  ].join(', ');
  return '${_camelizedString(step[0])}($parameters)';
}

String generateStepDart(
  String package,
  String line,
  String testerType,
  String customTesterName,
  bool hasDataTable,
  GeneratorOptions generatorOptions,
) {
  final methodName = getStepMethodName(line);

  final bddStep = _getStep(
    methodName,
    package,
    line,
    testerType,
    customTesterName,
    hasDataTable,
    generatorOptions,
  );
  return bddStep.content;
}

BddStep _getStep(
  String methodName,
  String package,
  String line,
  String testerType,
  String testerName,
  bool hasDataTable,
  GeneratorOptions generatorOptions,
) {
  //for now, predefined steps don't support testerType
  final factory =
      predefinedSteps[methodName] ??
      (_, _) => GenericStep(
        methodName,
        line,
        testerType,
        testerName,
        hasDataTable,
        generatorOptions,
      );
  return factory(package, line);
}

final predefinedSteps = <String, BddStep Function(String, String)>{
  'theAppIsRunning': (package, _) => TheAppInRunningStep(package),
  'iDismissThePage': (_, _) => IDismissThePage(),
  'iDontSeeIcon': (_, _) => IDontSeeIcon(),
  'iDontSeeRichText': (_, _) => IDontSeeRichText(),
  'iDontSeeText': (_, _) => IDontSeeText(),
  'iDontSeeWidget': (_, _) => IDontSeeWidget(),
  'iEnterIntoInputField': (_, _) => IEnterIntoInputField(),
  'iSeeDisabledElevatedButton': (_, _) => ISeeDisabledElevatedButton(),
  'iSeeEnabledElevatedButton': (_, _) => ISeeEnabledElevatedButton(),
  'iSeeExactlyWidgets': (_, _) => ISeeExactlyWidgets(),
  'iSeeIcon': (_, _) => ISeeIcon(),
  'iSeeMultipleTexts': (_, _) => ISeeMultipleTexts(),
  'iSeeMultipleWidgets': (_, _) => ISeeMultipleWidgets(),
  'iSeeRichText': (_, _) => ISeeRichText(),
  'iSeeText': (_, _) => ISeeText(),
  'iSeeWidget': (_, _) => ISeeWidget(),
  'iTapIcon': (_, _) => ITapIcon(),
  'iTapText': (_, _) => ITapText(),
  'iWait': (_, _) => IWait(),
};

/// Return an array of Strings where first element is the step name and the rest
/// are parameters.
List<String> parseRawStepLine(String stepLine) {
  final name = StringBuffer();
  final parameters = <String>[];
  final parameter = StringBuffer();

  var bracketsNesting = 0;
  for (var i = 0; i < stepLine.length; ++i) {
    final c = stepLine[i];
    if (c == '{') {
      // this is needed for cases when there is { inside parameter, like
      // When I run {func foo(){} func bar() {print('hey');}} code
      bracketsNesting++;
      if (bracketsNesting == 1) {
        // Found a parameter, skipping adding {
        continue;
      }
    }
    if (c == '}') {
      bracketsNesting--;
      if (bracketsNesting == 0) {
        // The end of the parameter, flushing the value, skiping }
        parameters.add(parameter.toString());
        parameter.clear();
        continue;
      }
    }

    if (bracketsNesting == 0) {
      name.write(c);
    } else {
      parameter.write(c);
    }
  }
  return [name.toString(), ...parameters];
}

String _camelizedString(String input) {
  final text = removeDiacritics(input)
      .replaceAll(examplesRegExp, '')
      .replaceAll(charactersAndNumbersRegExp, '')
      .replaceAll(repeatingSpacesRegExp, ' ')
      .trim()
      .replaceAll(' ', '_');
  return camelize(text);
}
