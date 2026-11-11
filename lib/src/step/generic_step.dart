import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/step/bdd_step.dart';
import 'package:bdd_widget_test/src/step_generator.dart';

class GenericStep implements BddStep {
  GenericStep(
    this.methodName,
    this.rawLine,
    this.testerType,
    this.customTesterName,
    this.hasDataTable,
    this.generatorOptions,
  );

  final String rawLine;
  final String methodName;
  final String testerType;
  final String customTesterName;
  final bool hasDataTable;
  final GeneratorOptions generatorOptions;

  @override
  String get content {
    final hasCustomHeaders = generatorOptions.customHeaders.isNotEmpty;
    final headerSection = hasCustomHeaders
        ? generatorOptions.customHeaders.join('\n')
        : "import 'package:flutter_test/flutter_test.dart';";

    return '${hasDataTable ? "import 'package:bdd_widget_test/data_table.dart' as bdd;\n" : ''}'
        '''
$headerSection

/// Usage: $rawLine
Future<void> $methodName($testerType $customTesterName${_getMethodParameters(rawLine, hasDataTable)}) async {
  throw UnimplementedError();
}
''';
  }

  String _getMethodParameters(String stepLine, bool hadDataTable) {
    return [
      ..._parametersInOrder(stepLine),
      if (hasDataTable) ', bdd.DataTable dataTable',
    ].join();
  }

  /// The step's parameters in the order [stepParts] gives them: each `{}`
  /// parameter is a `paramN`, each `<placeholder>` outside one a parameter
  /// named after it. A placeholder inside a `{}` parameter (`{<name>}`,
  /// `{'<name>'}`) is part of that parameter.
  Iterable<String> _parametersInOrder(String stepLine) sync* {
    var parameters = 0;
    for (final part in stepParts(stepLine)) {
      if (part.isParameter) {
        final type = _getGenericParameterType(part.text);
        yield ', $type param${++parameters}';
      } else {
        for (final placeholder in examplesRegExp.allMatches(part.text)) {
          yield ', dynamic ${placeholder.group(1)}';
        }
      }
    }
  }

  String _getGenericParameterType(String parameter) {
    if (parameter == 'true' || parameter == 'false') {
      return 'bool';
    }
    if (num.tryParse(parameter) != null) {
      return 'num';
    }
    if ((parameter.startsWith('"') && parameter.endsWith('"')) ||
        (parameter.startsWith("'") && parameter.endsWith("'"))) {
      return 'String';
    }
    return 'dynamic';
  }
}
