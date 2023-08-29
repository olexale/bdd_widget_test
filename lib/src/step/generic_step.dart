import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/step/bdd_step.dart';
import 'package:bdd_widget_test/src/step_generator.dart';

class GenericStep implements BddStep {
  GenericStep(
    this.methodName,
    this.rawLine,
    this.testerType,
    this.customTesterName,
  );

  final String rawLine;
  final String methodName;
  final String testerType;
  final String customTesterName;

  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

${getStepSignature(rawLine, testerType, customTesterName)} {
  throw UnimplementedError();
}
''';

  String getStepSignature(
    String stepLine,
    String testerType,
    String testerName,
  ) {
    final params = parseRawStepLine(stepLine).skip(1);
    if (params.isEmpty) {
      final examples = examplesRegExp.allMatches(stepLine);
      if (examples.isEmpty) {
        return 'Future<void> $methodName($testerType $testerName) async';
      } else {
        return _generateSignature(examples.length, testerName);
      }
    }
    return _generateSignature(params.length, testerName);
  }

  String _generateSignature(int paramsCount, String testerName) {
    final p = List.generate(paramsCount, (index) => index + 1);
    final methodParameters = p.map((p) => 'dynamic param$p').join(', ');
    return 'Future<void> $methodName($testerType $testerName, $methodParameters) async';
  }
}
