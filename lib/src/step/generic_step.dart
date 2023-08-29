import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/step/bdd_step.dart';
import 'package:bdd_widget_test/src/step_generator.dart';

class GenericStep implements BddStep {
  GenericStep(
    this.methodName,
    this.rawLine,
    this.testerType,
  );

  final String rawLine;
  final String methodName;
  final String testerType;

  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

${getStepSignature(rawLine, testerType)} {
  throw UnimplementedError();
}
''';

  String getStepSignature(String stepLine, String testerType) {
    final params = parseRawStepLine(stepLine).skip(1);
    if (params.isEmpty) {
      final examples = examplesRegExp.allMatches(stepLine);
      if (examples.isEmpty) {
        return 'Future<void> $methodName($testerType tester) async';
      } else {
        return _generateSignature(examples.length, testerType);
      }
    }
    return _generateSignature(params.length, testerType);
  }

  String _generateSignature(int paramsCount, String testerType) {
    final p = List.generate(paramsCount, (index) => index + 1);
    final methodParameters = p.map((p) => 'dynamic param$p').join(', ');
    return 'Future<void> $methodName($testerType tester, $methodParameters) async';
  }
}
