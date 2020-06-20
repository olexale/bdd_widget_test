import 'package:strings/strings.dart';

final parametersRegExp = RegExp(r'\{\S+\}', caseSensitive: false);
final parametersValueRegExp = RegExp(r'(?<=\{)\S+(?=\})', caseSensitive: false);

String getStepFilename(String stepText) {
  final step = getStepMethodName(stepText);
  return underscore(step);
}

String getStepMethodName(String stepText) {
  final text = stepText.replaceAll(parametersRegExp, '').replaceAll(' ', '_');
  return camelize(text);
}

String generateStepDart(String line) {
  final name = getStepMethodName(line);

  return '''
import 'package:flutter_test/flutter_test.dart';

${getStepSignature(line, name)} {
${getStepImplementation(name)}
}
''';
}

String getStepSignature(String stepLine, String name) {
  final params = parametersValueRegExp.allMatches(stepLine);
  if (params.isEmpty) {
    return 'Future<void> $name(WidgetTester tester) async';
  }

  final p = List.generate(params.length, (index) => index + 1);

  final methodParameters = p.map((p) => 'dynamic param$p').join(', ');
  return 'Future<void> $name(WidgetTester tester, $methodParameters) async';
}

String getStepImplementation(String methodName) => predefinedSteps[methodName] ?? '''  throw 'not implemented';''';

final predefinedSteps = <String, String>{
  'TheAppIsRunning': '''  await tester.pumpWidget(MyApp());''',
  'ISeeText': '''  expect(find.text(param1), findsOneWidget);''',
  'ISeeIcon': '''  expect(find.byIcon(param1), findsOneWidget);''',
};
