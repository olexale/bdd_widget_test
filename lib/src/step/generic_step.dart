import 'package:bdd_widget_test/src/step/bdd_step.dart';

final _parametersValueRegExp =
    RegExp(r'(?<=\{)\S+(?=\})', caseSensitive: false);

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
    final params = _parametersValueRegExp.allMatches(stepLine);
    if (params.isEmpty) {
      return 'Future<void> $methodName(WidgetTester tester) async';
    }

    final p = List.generate(params.length, (index) => index + 1);

    final methodParameters = p.map((p) => 'dynamic param$p').join(', ');
    return 'Future<void> $methodName(WidgetTester tester, $methodParameters) async';
  }
}
