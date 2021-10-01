import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/step/bdd_step.dart';

class GenericStep implements BddStep {
  GenericStep(this.methodName, this.rawLine);

  final String rawLine;
  final String methodName;

  @override
  String get content => '''
import 'package:flutter_test/flutter_test.dart';

${getStepSignature(rawLine)} {
  throw UnimplementedError();
}
''';

  String getStepSignature(String stepLine) {
    final params = parametersValueRegExp.allMatches(stepLine);
    if (params.isEmpty) {
      final examples = examplesRegExp.allMatches(stepLine);
      if (examples.isEmpty) {
        return 'Future<void> $methodName(WidgetTester tester) async';
      } else {
        return _generateSignature(examples.length);
      }
    }
    return _generateSignature(params.length);
  }

  String _generateSignature(int paramsCount) {
    final p = List.generate(paramsCount, (index) => index + 1);
    final methodParameters = p.map((p) => 'dynamic param$p').join(', ');
    return 'Future<void> $methodName(WidgetTester tester, $methodParameters) async';
  }
}
