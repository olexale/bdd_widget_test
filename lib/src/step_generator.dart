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

/// The step file's name, without the extension: "the app is running" becomes
/// `the_app_is_running`.
///
/// Never empty, because [getStepMethodName] refuses the step text that would
/// make it so — a `.dart` file with an empty stem is not a file anyone can
/// import, let alone name a function inside.
String getStepFilename(String stepText) {
  final step = getStepMethodName(stepText);
  return underscore(step);
}

String getStepMethodName(String stepText) {
  final identifier = stepIdentifier(stepText);
  if (identifier == null) {
    throw FormatException(unnamedStepError(stepText));
  }
  return identifier;
}

String getStepMethodCall(String stepLine, String customTesterName) {
  final step = parseRawStepLine(stepLine);
  final parameters = [customTesterName, ...step.skip(1)].join(', ');
  final identifier = stepIdentifier(stepLine);
  if (identifier == null) {
    throw FormatException(unnamedStepError(stepLine));
  }
  return '$identifier($parameters)';
}

/// The Dart identifier a step is named after, or null when its text names
/// nothing at all.
///
/// Step names are ASCII: [camelize] keeps letters, digits and underscores and
/// throws away everything else. Text written in another script —
/// `Given アプリが起動している` — is therefore thrown away entirely, and text opening
/// with a digit (`Given 2FA is on`) leaves behind a `2faisOn`, which Dart
/// refuses as a name. Both are valid Gherkin, and both used to generate
/// `import './step/.dart';` alongside an `await (tester);` call — two files that
/// do not compile, over a feature file that has nothing wrong with it.
///
/// A leading underscore is refused one step further along the same road:
/// `Given _debug mode is on` names `_debugModeIsOn`, which Dart accepts as a
/// declaration but keeps private to the step file holding it, so the generated
/// test that imports that file cannot call it.
///
/// The parser asks this question of every step before anything is generated, so
/// the mistake is reported against the `.feature` line that holds it (see
/// `_rejectUnnamedSteps` in `feature_parser.dart`). Refusing here is what keeps
/// any other caller from emitting that pair of files anyway.
String? stepIdentifier(String stepText) {
  final candidate = _stepNameCandidate(stepText);
  return _isUsable(candidate) ? candidate : null;
}

/// The name a step's text boils down to, before anything asks whether Dart can
/// use it.
String _stepNameCandidate(String stepText) =>
    _camelizedString(parseRawStepLine(stepText).first);

/// Whether the generated test can import a step file naming its function
/// [candidate] and then call it.
bool _isUsable(String candidate) =>
    candidate.isNotEmpty && !_unusableStart.hasMatch(candidate);

/// What such a function may not start with: a digit, which is no name at all,
/// or an underscore, which is a name only the step file itself can see.
final RegExp _unusableStart = RegExp(r'^[\d_]');

/// The mistake behind [stepIdentifier] returning null, in the words both
/// callers use: the parser puts the step's position in front of it, the
/// generators have no position to give and stand alone.
String unnamedStepError(String stepText) =>
    "step '${stepText.trim()}' produces no valid Dart identifier: "
    '${_whyUnusable(_stepNameCandidate(stepText))}';

/// Why [_isUsable] turned [candidate] down, and what to do about it. The
/// branches answer that method's conditions one for one, so a new condition
/// wants a branch here to explain it.
String _whyUnusable(String candidate) {
  if (candidate.isEmpty) {
    return 'its text holds no ASCII letter or digit to name it after. '
        'Rename the step, or give it a word of ASCII';
  }
  if (candidate.startsWith('_')) {
    return "'$candidate' is private to the step file it would be written in, "
        'where the generated test cannot call it. Rename the step so its text '
        'does not open with an underscore';
  }
  return "'$candidate' is not a name Dart accepts. Rename the step so its "
      'text does not open with a digit';
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
