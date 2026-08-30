import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:test/test.dart';

void main() {
  // A step's name is what is left of its text once everything that is not an
  // ASCII word character is thrown away. Where nothing is left, naming the step
  // is refused rather than left empty: an empty name generates a step file
  // called `.dart` and a call to nothing, and neither of them compiles.
  test('Step text in another script names no step file', () {
    expect(
      () => getStepFilename('アプリが起動している'),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('アプリが起動している'),
            contains('produces no valid Dart identifier'),
            contains('holds no ASCII letter or digit'),
          ),
        ),
      ),
    );
  });

  test('Step text in another script names no method', () {
    expect(
      () => getStepMethodName('Привіт світе'),
      throwsA(isA<FormatException>()),
    );
  });

  test('Step text in another script names no call', () {
    expect(
      () => getStepMethodCall('アプリが起動している{1}', 'tester'),
      throwsA(isA<FormatException>()),
    );
  });

  // `2faisOn` is not empty, and Dart refuses it as a name all the same.
  test('Step text opening with a digit names nothing either', () {
    expect(
      () => getStepMethodName('2FA is on'),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains("'2faisOn' is not a name Dart accepts"),
            contains('does not open with a digit'),
          ),
        ),
      ),
    );
  });

  test('A step whose whole name is a parameter names nothing', () {
    expect(() => getStepMethodName('{5}'), throwsA(isA<FormatException>()));
  });

  // `_debugModeIsOn` is a name Dart takes, and one only the step file it is
  // declared in can see — the generated test importing that file cannot call
  // it.
  test('Step text opening with an underscore names nothing either', () {
    expect(
      () => getStepMethodName('_debug mode is on'),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(
            contains("'_debugModeIsOn' is private to the step file"),
            contains('does not open with an underscore'),
          ),
        ),
      ),
    );
    expect(
      () => getStepFilename('_debug mode is on'),
      throwsA(isA<FormatException>()),
    );
  });

  test('ASCII step text names a method, a file and a call', () {
    expect(getStepMethodName('the app is running'), 'theAppIsRunning');
    expect(getStepFilename('the app is running'), 'the_app_is_running');
    expect(
      getStepMethodCall("I see {'0'} text", 'tester'),
      "iSeeText(tester, '0')",
    );
  });

  // Accented Latin is folded onto ASCII before the stripping, so this keeps
  // working — the limit is the script, not the accents.
  test('Accented Latin step text still names a step', () {
    expect(
      getStepFilename('los diacríticos son útil'),
      'los_diacriticos_son_util',
    );
  });
}
