import 'package:strings/strings.dart';

String getStepFilename(String stepText) {
  final step = getStepMethodName(stepText);
  return underscore(step);
}

String getStepMethodName(String stepText) {
  final lines = stepText.split(' ');
  final step = lines.map((part) {
    if (part.startsWith('{') && part.endsWith('}')) {
      return '';
    }
    return part[0].toUpperCase() + part.substring(1).toLowerCase();
  }).join();
  return step;
}

String getStepSignature(String stepLine) {
  final name = getStepMethodName(stepLine);

  final regExp = RegExp(r'(?<=\{)\S+(?=\})', caseSensitive: false);
  final params = regExp.allMatches(stepLine);
  if (params.isEmpty) {
    return 'Future<void> $name(WidgetTester tester) async';
  }

  final p = List.generate(params.length, (index) => index + 1);

  final methodParameters = p.map((p) => 'dynamic param$p').join(', ');
  return 'Future<void> $name(WidgetTester tester, $methodParameters) async';
}
